class Student < ActiveRecord::Base
  require 'rubyXL'
  #paginates_per 30
 # attr_accessible :first_name, :middle_name, :last_name, :email, :mobile, :parent_name, :p_mobile, :p_email, :address, :group, :rank
  resourcify
  #has_many
  has_many :exam_absents
  has_many :exam_results
  has_many :class_students
  has_many :removed_class_students
  has_many :jkci_classes, through: :class_students
  has_many :class_catlogs
  has_many :daily_teaching_points, through: :class_catlogs 
  has_many :exam_catlogs
  has_many :exams, through: :exam_catlogs 
  has_many :student_subjects
  has_many :subjects, through: :student_subjects
  has_many :student_fees
  belongs_to :batch
  belongs_to :user
  belongs_to :standard
  
  default_scope { where(organisation_id: Organisation.current_id) }  
  scope :enable_students, -> { where(is_disabled: false) }
  
  scope :default_students, -> (days) { where("last_present is not ? && last_present < ?", nil, Time.now - days.days) }
  
  validates :standard_id, presence: true
  validates :batch_id, presence: true
  validates :first_name, presence: true
  validates :last_name, presence: true
  #validates :parent_name, presence: true
  validates :p_mobile, presence: true

  before_destroy :destroy_dependency
  
  def all_exams
    #Exam.where(std: std, is_active: true)
    Exam.where("jkci_class_id in (?)  or ?", self.jkci_classes.map(&:id), exam_query)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def short_name
    "#{initl} #{last_name}"
  end

  def sms_mobile
    return p_mobile.present? ?  "91" << p_mobile : nil
  end

  def add_students_subjects(o_subjects, organisation)
    self.subjects.delete(self.subjects)
    standard.subjects.compulsory.each do |sub|
      self.student_subjects.build({subject_id: sub.id, organisation_id: organisation.id}).save
    end
    if o_subjects.present?
      standard.subjects.where(id: o_subjects.map(&:to_i), is_compulsory: false).each do |sub|
        self.student_subjects.build({subject_id: sub.id, organisation_id: organisation.id}).save
      end
    end
  end

  def activate_sms
    self.update_attributes({enable_sms: true})
    Delayed::Job.enqueue ActivationSms.new(activate_sms_message)
  end

  def deactivate_sms
    self.update_attributes({enable_sms: false})
    Delayed::Job.enqueue ActivationSms.new(deactivate_sms_message)
  end
  
  def exam_query
    query = " "
    ids = self.jkci_classes.map(&:id)
    ids.each do |class_id|
      query << "class_ids like '%,#{class_id},%'"
      unless ids.last == class_id
        query << " or "
      end
    end
    query
  end

  def classes_names
    self.jkci_classes.active.map(&:class_name).join(', ')
  end

  def class_info
    jkci_classes.select([:id, :class_name, :class_start_time, :teacher_id]).includes([:teacher])
  end

  def exams_graph_reports(graph_type="month", type = 'all' , subject_id = nil)
    reports = {}
    exam_katlogs = self.exam_catlogs.joins(:exam)
    if subject_id.present?
      exam_katlogs = exam_katlogs.where("exams.subject_id = ?", subject_id)
    end
    if graph_type == "day"
      reports = exam_katlogs.where("exams.exam_date > ?", Date.today - 50.days).group_by_period(graph_type.to_sym, "exams.exam_date", format: "%d-%b").average(:percentage).map{|x,y| {x =>  y.to_f.round(2)}}
    end
    if graph_type == "week"
      reports = exam_katlogs.where("exams.exam_date > ?", Date.today - 30.weeks).group_by_period(graph_type.to_sym, "exams.exam_date", format: "%d-%b", week_start: :mon).average(:percentage).map{|x,y| {x =>  y.to_f.round(2)}}
    end
    if graph_type == "month"
      reports = exam_katlogs.where("exams.exam_date > ?", Date.today - 10.months).group_by_period(graph_type.to_sym, "exams.exam_date", format: "%b-%Y").average(:percentage).map{|x,y| {x =>  y.to_f.round(2)}}
    end
    if reports == []
      reports = {} 
    else
      reports = reports.reduce(:merge)
    end
    
    if type == 'all'
      reports = reports.select{|x,y| y > 0} 
      return reports.keys, reports.values
    else
      reports
    end
  end

  def exams_graph_reports_by_subject(graph_type="month")
    reports  = {};
    headers = [];
    g_reports = {};
    
    if graph_type == 'day'
      headers = ((Date.today - 50.days)..Date.today).to_a.map{|date| date.strftime("%d-%b")}
    elsif graph_type == 'week'
      date = Date.today.beginning_of_week
      headers = ((date - 30.weeks)..date).time_step(1.week).to_a.map{|date| date.strftime("%d-%b")}
    elsif graph_type == 'month'
      headers = ((Date.today - 10.months)..Date.today).time_step(1.month).to_a.map{|date| date.strftime("%b-%Y")}
    end

    p self.subjects
    self.subjects.each do |subject|
      reports[subject.name] = self.exams_graph_reports(graph_type, 'subject' , subject.id)
      g_reports[subject.name] = [0]* headers.size
    end
    
    headers.each_with_index do |h_date, index|
      g_reports.keys.each do |key|
        g_reports[key][index] = reports[key][h_date] || 0
      end
    end
    return headers, g_reports.keys, g_reports.values 
  end
  
  def learned_point(class_id= nil, min_date_filter = nil, max_date_filter = nil, only_presents= nil, only_absents= nil)
    jk_catlogs = class_catlogs.order('id desc')#.includes([:daily_teaching_points])

    if class_id.present?
      jk_catlogs = jk_catlogs.where(jkci_class_id: class_id)
    end

    if min_date_filter.present?
      jk_catlogs = jk_catlogs.where("date >= ?", min_date_filter)
    end

    if max_date_filter.present?
      jk_catlogs = jk_catlogs.where("date <= ?", max_date_filter)
    end
    
    if only_absents.present?
      jk_catlogs = jk_catlogs.where(is_present: false)
    end
    return jk_catlogs
  end

  def class_exams(class_id= nil, min_date_filter = nil, max_date_filter = nil)
    ex_catlogs = exam_catlogs.includes([:exam]).completed.order('id desc')#.includes([:daily_teaching_points])
    
    if class_id.present?
      ex_catlogs = ex_catlogs.where(jkci_class_id: class_id)
    end
    
    if min_date_filter.present?
      ex_catlogs = ex_catlogs.where("date >= ?", min_date_filter)
    end
    
    if max_date_filter.present?
      ex_catlogs = ex_catlogs.where("date <= ?", max_date_filter)
    end
    return ex_catlogs
  end

  def update_presnty
    self.update_attributes({last_present: Time.now})
  end

  def exam_table_format
    table = [["Index", "Exam Name", "Exam Type", "Class", "Date", "Is Present", "Marks", "Rank"]]
    self.exam_catlogs.each_with_index do |exam_catlog, index|
      table << ["#{index+1}", "#{exam_catlog.exam.name}", "#{exam_catlog.exam.exam_type}", "#{exam_catlog.jkci_class.class_name}", "#{exam_catlog.exam.exam_date.to_date}", "#{exam_catlog.is_present}", "#{exam_catlog.marks.to_i}/#{exam_catlog.exam.marks}", "#{exam_catlog.rank}"]
    end
    table
  end

  def activate_sms_message
    url_arry = []
    message = "#{self.short_name}'s notification updates has been activaed. JKSai!!"
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.p_mobile}&message=#{message}"
    if self.sms_mobile.present?
      url_arry = [url, message, self.id, self.organisation_id, self.p_mobile]
    end
    url_arry
  end

  def deactivate_sms_message
    url_arry = []
    message = "#{self.short_name}'s notification updates has been deactivaed.Please contact us JKSai!!"
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.p_mobile}&message=#{message}"
    if self.sms_mobile.present?
      url_arry = [url, message, self.id, self.organisation_id, self.p_mobile]
    end
    url_arry
  end

  def destroy_dependency
    self.exam_absents.destroy_all
    self.exam_results.destroy_all
    self.class_students.destroy_all
    self.class_catlogs.destroy_all
    self.exam_catlogs.destroy_all
    self.student_subjects.destroy_all
  end

  def as_json(options= {})
    options.merge({
                    first_name: first_name, 
                    last_name: last_name, 
                    email: email, 
                    mobile: mobile, 
                    parent_name: parent_name, 
                    p_mobile: p_mobile, 
                    p_email: p_email, 
                    address: address,  
                    rank: rank, 
                    middle_name: middle_name, 
                    batch_id: batch_id, 
                    gender: gender, 
                    initl: initl,
                    parent_occupation: parent_occupation,
                    standard_id: standard_id
                  })
  end

  def subject_json(options= {})
    options.merge({
                    id: id,
                    name: name,
                    o_subjects: subjects.optional.map(&:id)
                  })
  end

  def catlog_json(absent_list = [] , options={})
    options.merge({
                    id: id,
                    name: name,
                    p_mobile: p_mobile,
                    is_present: !absent_list.flatten.include?(self.id)
                  })
  end

  def sub_class_remaining_json(absent_list = [] , options={})
    options.merge({
                    id: id,
                    name: name,
                    p_mobile: p_mobile
                  })
  end

  def sub_class_json(options= {})
    options.merge({
                    id: id,
                    name: "#{first_name} #{last_name}", 
                    mobile: mobile, 
                    parent_name: parent_name, 
                    p_mobile: p_mobile, 
                    batch: batch.name,
                    standard: standard.std_name
                  })
  end

  def assign_json(options ={})
    options.merge({
                    id: id,
                    name: "#{first_name} #{last_name}", 
                    p_mobile: p_mobile
                  })
  end

  def sync_json(options = {})
    options.merge({
                    id: id,
                    first_name: first_name, 
                    last_name: last_name, 
                    standard_id: standard_id,
                    middle_name: middle_name
                  })
  end

  
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names
      all.each do |product|
        csv << product.attributes.values_at(*column_names)
      end
    end
  end
end
