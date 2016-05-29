class JkciClass < ActiveRecord::Base
  include SendingSms
  belongs_to :teacher
  has_many :class_students
  has_many :students, through: :class_students
  has_many :removed_class_students
  has_many :exams
  has_many :daily_teaching_points
  has_many :class_catlogs
  belongs_to :batch
  #belongs_to :subject
  belongs_to :standard
  has_many :subjects, through: :standard
  belongs_to :organisation
  belongs_to :current_chapter, class_name: "Chapter", foreign_key: "current_chapter_id"
  has_many :sub_classes
  has_many :exam_notifications, through: :exams, source: :notifications
  has_many :dtp_notifications, through: :daily_teaching_points, source: :notifications
  has_many :exam_catlogs
  has_many :notifications
  has_many :pending_notifications, -> { where("is_completed in (?) && verification_require = ?", [nil, false], true)}, class_name: "Notification"
  has_many :time_tables
  has_many :off_classes
  has_many :student_fees
  
  has_many :chapters, through: :subject

  validates :class_name, presence: true
  validates :batch_id, presence: true
  validates :organisation_id, presence: true
  #validates :standard_id, presence: true, uniqueness: { scope: [:organisation_id, :batch_id],
  #  message: "should happen once per organisation per batch" }
  
  #default_scope  {where(is_active: true)} 
  default_scope { where(organisation_id: Organisation.current_id) }
  scope :active, -> { where(is_current_active: true, is_active: true) }

  after_create :generate_time_table

  def manage_students(associate_students, organisation)
    organisation.students.where(id: associate_students).each do |student|
      #organisation.class_students.where("jkci_class_id not in (?)", [self.id]).where(student_id: student).destroy_all
      student.update_attributes({batch_id: self.batch_id})
      removed_class_student = self.removed_class_students.where(student_id: student.id).first
      klass_student = self.class_students.find_or_initialize_by({student_id: student.id, organisation_id: self.organisation_id, batch_id: self.batch_id})
      klass_student.collected_fee = removed_class_student.collected_fee if removed_class_student.present?
      klass_student.save
      removed_class_student.destroy if removed_class_student.present?
    end
  end
  
  def class_name_with_batch
    "#{class_name}-#{batch.name}"
  end

  def remove_student_from_class(associate_student, organisation)
    #self.students.delete(organisation.students.where(id: associate_student))
    klass_students = self.class_students.where(student_id: associate_student)
    RemovedClassStudent.add_removed_class_students(klass_students.to_a)
    klass_students.destroy_all
  end
  
  def jk_exams
    Exam.roots.where("(jkci_class_id = ? OR class_ids like '%,?,%') AND organisation_id = ?", self.id, self.id, self.organisation_id)
  end

  def role_exam_notifications(user)
    user_roles = user.roles.select([:name]).map(&:name).map(&:to_sym)
    notification_roles = NOTIFICATION_ROLES.slice(*user_roles).values.flatten
    exam_notifications.where(actions: notification_roles, is_completed: false)
  end

  def role_exam_notifications(user)
    user_roles = user.roles.select([:name]).map(&:name).map(&:to_sym)
    notification_roles = NOTIFICATION_ROLES.slice(*user_roles).values.flatten
    exam_notifications.where(actions: notification_roles, is_completed: false)
  end

  def fill_catlog(present_list, dtp_id, date)
    self.students.each do |student|
     create_catlog(self.id, student.id, dtp_id, date, present_list.map(&:to_i).include?(student.id))
    end
  end

  def add_sub_class_students(students, sub_class)
    class_students.where("student_id in (?)", students.split(',').map(&:to_i)).each do |class_student|
      class_student.add_sub_class(sub_class)
    end
  end

  def remove_sub_class_students(student, sub_class)
    class_students.where("student_id in (?)", student).each do |class_student|
      class_student.remove_sub_class(sub_class.to_i)
    end
  end
    
  def exams_count
    [self.class_name, self.exams.count]
  end
  
  def create_catlog(class_id, student_id, dtp_id, date, is_present)
    class_catlog = ClassCatlog.where({jkci_class_id: class_id, student_id: student_id, daily_teaching_point_id: dtp_id, date: date }).first_or_initialize
    class_catlog.update_attributes({is_present: is_present})
  end

  def sub_classes_students(s_c_ids, ex_subject=nil)
    # s_c_ids is array of sub classes
    sub_classes_ids = self.sub_classes.where("id in (?)", s_c_ids).map(&:id)
    sc_string = "sub_class like '%,00,%'"
    sub_classes_ids.each do |sc_id|
      sc_string << " || "# unless sub_classes_ids.first == sc_id
      sc_string << "sub_class like '%,#{sc_id},%'"
    end
    if ex_subject.present? 
      ex_subject.students.joins(:class_students).where(" #{sc_string} and class_students.jkci_class_id = ?", self.id)
    else
      student_ids = self.class_students.where(sc_string).map(&:student_id)
      students.where("students.id in (?)", student_ids)
    end
  end

  def save_class_roll_number(roll_numbers)
    roll_numbers.each do |roll_number|
      self.class_students.where(id: roll_number["id"]).first.update_attributes({roll_number: roll_number["roll_number"].present? ? roll_number["roll_number"] : nil})
    end
  end
  
  def chapters_table_format(subject)
    table = [["Chapters", "Points"]]
    chapters = subject.chapters
    chapters.each_with_index do |chapter, index|
      table << ["#{chapter.name}", "#{chapter.points_name}"]
    end
    table
  end

  def exams_table_format
    table = [["Id", "Subject", "Type", "Marks", "Date", "Absents Count", "Published date"]]

    self.exams.order("exam_date desc").each do |exam|
      table << ["#{exam.id }", "#{exam.subject.try(:name)}", "#{exam.exam_type}", "#{exam.marks}", "#{exam.exam_date.try(:to_date)}", "#{exam.absents_count}", "#{exam.published_date.try(:to_date) || 'Not Published'}"]
    end
    table
  end


  def upgrade_batch(student_list, organisation, standard_id)
    next_batch = self.batch.next
    next_standard = organisation.standards.where(id: standard_id).first
    next_old_class = JkciClass.where(standard_id: standard_id, batch_id: self.batch_id).first
    if next_batch && next_standard && next_old_class
      new_class = organisation.jkci_classes.find_or_initialize_by({batch_id: next_batch.id, standard_id: self.standard_id, organisation_id: self.organisation_id})
      new_class.class_name = "#{new_class.standard.std_name}-#{next_batch.name}"
      new_class.save

      new_next_class = JkciClass.find_or_initialize_by({batch_id: next_batch.id, standard_id: next_standard.id, organisation_id: Organisation.current_id })
      new_next_class.organisation_id = next_old_class.organisation_id
      new_next_class.class_name = "#{new_next_class.standard.std_name}-#{next_batch.name}"
      new_next_class.fee = next_old_class.fee
      new_next_class.save
      new_next_class.make_active_class(next_old_class.organisation)
      if student_list.present?
        Student.where(id: student_list).update_all({standard_id: next_standard.id, batch_id: next_batch.id, organisation_id: next_old_class.organisation_id})
        old_class_students = self.class_students.includes(:student).where(student_id: student_list)
        RemovedClassStudent.add_removed_class_students(old_class_students.to_a)
        old_class_students.update_all({jkci_class_id: new_next_class.id, roll_number: nil, organisation_id: next_old_class.organisation_id, sub_class: nil, batch_id: new_next_class.batch_id, collected_fee: 0})
        new_next_class.students.map{|c_student| c_student.add_students_subjects(nil, next_old_class.organisation)}
      end
      
      new_next_class.calculate_students_count
      self.calculate_students_count
    end
    new_next_class
  end
  
  def daily_teaching_table_format
    table = [["Id", "Subject", "Chapter", "Points", "Date", "Sms Sent", "Divisions"]]

    self.daily_teaching_points.order(chapter_id: :desc,date: :desc).each_with_index do |dtp, index|
      table << ["#{index}", "#{dtp.subject.try(:name)}", "#{dtp.chapter.try(:name)}", "#{dtp.points}", "#{dtp.date.try(:to_date)}", "#{dtp.is_sms_sent}", "#{dtp.sub_classes}"]
    end
    table
  end
  
  def calculate_students_count
    JkciClass.reset_counters(self.id, :class_students)
  end
  
  def class_students_table_format
    table = [["Id", "Name", "Parent Mobile", "Subjects"]]

    self.students.each_with_index do |student, index|
      table << ["#{index+ 1 }", "#{student.name}", "#{student.p_mobile}", "#{student.subjects.map(&:std_name).join('  |  ')}"]
    end
    table
  end

  def students_table_format(sub_class_ids)
    table = [["Id", "Name", "Parent Mobile", "Is Present", "", "Id", "Name", "Parent Mobile", "Is Present", ""]]
    if sub_class_ids.present?
      c_students = self.sub_classes_students(sub_class_ids.split(',')).select("class_students.roll_number, students.*").order("roll_number asc")
    else
      c_students = self.students.select("class_students.roll_number, students.*").order("roll_number asc")
    end
    c_students.in_groups_of(2).each do |student_groups|
      table_group = []
      student_groups.each do |student|
        if student
          table_group << ["#{student.roll_number}", "#{student.name}", "#{student.p_mobile}", "", ""] 
        else
          table_group << ["", "", "", "", ""] 
        end
      end
      table << table_group.flatten
    end
    table
  end

  def get_sub_classes(ids)
    if ids.blank?
      self.sub_classes.as_json
    else
    self.sub_classes.where(id: ids).as_json
    end
  end

  def generate_time_table
    self.time_tables.find_or_initialize_by({organisation_id: self.organisation_id}).save
  end

  def check_duplicates(hardCheck = true)
    if hardCheck
      class_students.update_all({duplicate_field: "", is_duplicate: false, is_duplicate_accepted: false})
    end
    students.select( :first_name,:last_name).group(:first_name, :last_name).having("count(*) > 1").each do |student|
      ids = students.select(:id, :first_name,:last_name).where(first_name: student.first_name, last_name: student.last_name).map(&:id)
      class_students.where(student_id: ids, is_duplicate: false).update_all({is_duplicate: true, duplicate_field: "Name"})
    end
    
    students.select(:p_mobile).group(:p_mobile).having("count(*) > 1").each do |student|
      ids = students.select(:id, :p_mobile).where(p_mobile: student.p_mobile).map(&:id)
      class_students.where(student_id: ids, is_duplicate: false).each do |class_student|
        class_student.update_attributes({is_duplicate: true, duplicate_field: class_student.try(:duplicate_field).to_s + " Mobile"})
      end
    end
    
    class_students.joins(:student).where("students.batch_id != ?", self.batch_id).update_all({is_duplicate: true, duplicate_field: "Batch"})
    self.update_attributes({is_student_verified: false})
  end

  def make_active_class(organisation)
    #self.standard.jkci_classes.update_all({is_current_active: false})
    self.update_attributes({is_current_active: true})
  end

  def make_deactive_class(organisation)
    #self.standard.jkci_classes.update_all({is_current_active: false})
    self.update_attributes({is_current_active: false})
  end

  def self.import_students_excel(file, self_class, org)
    spreadsheet = open_spreadsheet(file)
    
    header = []
    transaction do
      spreadsheet[0].each_with_index { |row, index|
        if index == 0
          is_valid_class = (row && (row[0].value == "eraCord-#{org.id}-#{self_class.id}"))
          return false unless is_valid_class
        elsif index == 1
          row && row.each_with_index { |cell|
            val = cell && cell.value
            header << val if val
          }
          return false if (header & STUDENT_HEADER).size != STUDENT_HEADER.size
        else
          vals = [];
          row && row.each_with_index { |cell|
            val = cell && cell.value || ""
            vals << val 
          }
          record = header.zip(vals).to_h
          student = org.students.find_or_initialize_by(record.slice("first_name", "last_name", "p_mobile"))
          if student.id.present?
            org.class_students.where("jkci_class_id not in (?) and student_id in (?)", [self_class.id], [student.id]).destroy_all
            student.update_attributes({batch_id: self_class.batch_id, standard_id: self_class.standard_id})
          else
            student.initl = record['initl']
            student.middle_name = record['middle_name']
            student.gender = record['gender']
            student.mobile = record['mobile']
            student.parent_name = record['parent_name']
            student.standard_id = self_class.standard_id
            student.batch_id = self_class.batch_id
            student.save! if student.valid?
          end
        end
      }
    end

    transaction do
      spreadsheet[0].each_with_index { |row, index|
        vals = [];
        row && row.each_with_index { |cell|
          val = cell && cell.value || ""
          vals << val 
        }
        record = header.zip(vals).to_h
        student = org.students.where(record.slice("first_name", "last_name", "p_mobile")).first
        if student.present?
          self_class.class_students.find_or_initialize_by({student_id: student.id, organisation_id: self_class.organisation_id, batch_id: self_class.batch_id}).save
        end
      }
    end
    return true
  end
  
  def self.open_spreadsheet(file)
    case File.extname(file.original_filename)
    when ".csv" then Csv.new(file.path, nil, :ignore)
      #when ".xls" then Roo::Excel.new(file.path, packed: nil, file_warning: :ignore)
    when ".xlsx" then RubyXL::Parser.parse(file.path)
    else raise "Unknown file type: #{file.original_filename}"
    end
  end

  def absenty_graph_reports(graph_type="day")
    reports = {}
    if graph_type == "day"
      reports = self.class_catlogs.joins(:daily_teaching_point).where("is_present in (?) && daily_teaching_points.date > ?", [false, nil], Date.today - 30.days).group_by_period(graph_type.to_sym, "daily_teaching_points.date", format: "%d-%b").count
    end
    if graph_type == "week"
      reports = self.class_catlogs.joins(:daily_teaching_point).where("is_present in (?) && daily_teaching_points.date > ?",  [false, nil], Date.today - 15.weeks).group_by_period(graph_type.to_sym, "daily_teaching_points.date", format: "%d-%b", week_start: :mon).count
    end
    if graph_type == "month"
      reports = self.class_catlogs.joins(:daily_teaching_point).where("is_present in (?) && daily_teaching_points.date > ?",  [false, nil], Date.today - 10.months).group_by_period(graph_type.to_sym, "daily_teaching_points.date", format: "%b-%Y").count
    end
    reports
  end

  def exams_graph_reports(graph_type="day")
    reports = {}
    if graph_type == "day"
      reports = self.exams.where("exam_date > ?", Date.today - 30.days).group_by_period(graph_type.to_sym, "exam_date", format: "%d-%b").count
    end
    if graph_type == "week"
      reports = self.exams.where("exam_date > ?", Date.today - 15.weeks).group_by_period(graph_type.to_sym, "exam_date", format: "%d-%b", week_start: :mon).count
    end
    if graph_type == "month"
      reports = self.exams.where("exam_date > ?", Date.today - 10.months).group_by_period(graph_type.to_sym, "exam_date", format: "%b-%Y").count
    end
    reports
  end
  
  def off_class_graph_reports(graph_type="day")
    reports = {}
    if graph_type == "day"
      reports = self.off_classes.where("date > ?", Date.today - 30.days).group_by_period(graph_type.to_sym, "date", format: "%d-%b").count
    end
    if graph_type == "week"
      reports = self.off_classes.where("date > ?", Date.today - 15.weeks).group_by_period(graph_type.to_sym, "date", format: "%d-%b", week_start: :mon).count
    end
    if graph_type == "month"
      reports = self.off_classes.where("date > ?", Date.today - 10.months).group_by_period(graph_type.to_sym, "date", format: "%b-%Y").count
    end
    reports
  end

  def presenty_catlog(params = '', start_date = Date.today - 1.months, end_date = Date.today, isDownload = false)
    start_date = Date.today - 1.months unless start_date.present?
    end_date = Date.today unless end_date.present?
    dates = (start_date..end_date).to_a
    date_hash = {}
    dates.each_with_index do |date, index|
      date_hash[date.strftime("%m-%d")] = index
    end
    
    present_reports ={}
    students.select([:id, :first_name, :last_name, :p_mobile, :parent_name]).each do |student|
      present_reports["#{student.first_name} #{student.last_name}"] ||= ([{id: "#{student.id}", name: "#{student.first_name} #{student.last_name}", parent_name: "#{student.parent_name}", p_mobile: "#{student.p_mobile}"}] << ['p']*dates.count).flatten
    end

    # ---- For Class Presenty only ##
    if params == 'class_catlogs'
      klass_catlogs = class_catlogs.joins(:student).select("class_catlogs.id, students.first_name as first_name, students.last_name as last_name, students.p_mobile as p_mobile, class_catlogs.date").where("date <= ? and date >= ?", end_date, start_date)
      klass_catlogs.each do |class_catlog|
        present_reports["#{class_catlog.first_name} #{class_catlog.last_name}"] ||= (["#{class_catlog.first_name} #{class_catlog.last_name}"] << ['p']*dates.count).flatten
        present_reports["#{class_catlog.first_name} #{class_catlog.last_name}"][date_hash[class_catlog.date.strftime("%m-%d")]+1] = "a"
      end
    end
    

    # ---- For Exam Presenty only ##
    if params == 'exams'
      kexam_catlogs = exam_catlogs.joins(:student, :exam).select("exam_catlogs.id, students.first_name as first_name, students.last_name as last_name, students.p_mobile as p_mobile, exams.exam_date as exam_date, exam_catlogs.is_present").where("exam_date <= ? and exam_date >= ? and is_present = ?", end_date, start_date, false)
      kexam_catlogs.each do |exam_catlog|
        if exam_catlog.exam_date.present?
          present_reports["#{exam_catlog.first_name} #{exam_catlog.last_name}"] ||= (["#{exam_catlog.first_name} #{exam_catlog.last_name}"] << ['p']*dates.count).flatten
          present_reports["#{exam_catlog.first_name} #{exam_catlog.last_name}"][date_hash[exam_catlog.exam_date.strftime("%m-%d")]+1] = "a"
        end
      end
    end
    reports = []
    reports << ([""] << date_hash.keys).flatten
    reports << present_reports.values

    return reports
  end

  def expected_fee_collections
    (fee || 0) * (class_students_count + self.removed_class_students.count)
  end
  
  def subject_json(options={})
    options.merge({
                    id: id,
                    name: class_name,
                    o_subjects: subjects.optional.as_json
                  })
  end

  def student_filter_json(options={})
    options.merge({
                    id: id,
                    name: class_name
                  })
  end

  def unassigned_json(options = {})
    options.merge({
                    id: id,
                    name: class_name,
                    organisation_id: organisation_id,
                    organisation_name: organisation.name,
                    mobile: organisation.mobile,
                    email: organisation.email
                    
                  })
  end

  def organisation_class_json(options = {})
    options.merge({
                    id: id,
                    name: class_name,
                    organisation_id: organisation_id,
                    organisation_name: organisation.name,
                    mobile: organisation.mobile,
                    email: organisation.email,
                    is_current_active: is_current_active,
                    students_count: class_students_count,
                    fee: fee
                  })
  end

  def batch_json(options ={})
    options.merge({
                    class_name: class_name,
                    batch: batch.name,
                    is_next_batch: batch.next.present?,
                    next_batch_name: batch.next.try(:name)
                  })
    
  end
  
end
