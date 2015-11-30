class Student < ActiveRecord::Base

  #paginates_per 30
 # attr_accessible :first_name, :middle_name, :last_name, :email, :mobile, :parent_name, :p_mobile, :p_email, :address, :group, :rank
  resourcify
  #has_many
  has_many :exam_absents
  has_many :exam_results
  has_many :class_students
  has_many :jkci_classes, through: :class_students
  has_many :class_catlogs
  has_many :daily_teaching_points, through: :class_catlogs 
  has_many :exam_catlogs
  has_many :exams, through: :exam_catlogs 
  has_many :student_subjects
  has_many :subjects, through: :student_subjects
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
  validates :parent_name, presence: true
  validates :p_mobile, presence: true
  
  
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

  def add_students_subjects(o_subjects)
    self.subjects.delete(self.subjects)
    self.subjects << standard.subjects.compulsory
    self.subjects << standard.subjects.where(id: o_subjects.map(&:to_i), is_compulsory: false) if o_subjects.present?
      
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
      url_arry = [url, message, self.id, self.organisation_id]
    end
    url_arry
  end

  def deactivate_sms_message
    url_arry = []
    message = "#{self.short_name}'s notification updates has been deactivaed.Please contact us JKSai!!"
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.p_mobile}&message=#{message}"
    if self.sms_mobile.present?
      url_arry = [url, message, self.id, self.organisation_id]
    end
    url_arry
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
                    standard_id: standard_id
                  })
  end
end
