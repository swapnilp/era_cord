class JkciClass < ActiveRecord::Base
  include SendingSms
  belongs_to :teacher
  has_many :class_students
  has_many :students, through: :class_students
  has_many :exams
  has_many :daily_teaching_points
  has_many :class_catlogs
  belongs_to :batch
  belongs_to :subject
  belongs_to :standard
  has_many :subjects, through: :standard
  belongs_to :organisation
  belongs_to :current_chapter, class_name: "Chapter", foreign_key: "current_chapter_id"
  has_many :sub_classes
  has_many :exam_notifications, through: :exams, source: :notifications
  has_many :dtp_notifications, through: :daily_teaching_points, source: :notifications
  has_many :exam_catlogs
  has_many :notifications
  
  has_many :chapters, through: :subject

  validates :class_name, presence: true
  validates :batch_id, presence: true
  validates :organisation_id, presence: true
  validates :standard_id, presence: true, uniqueness: { scope: [:organisation_id, :batch_id],
    message: "should happen once per organisation per batch" }
  
  #default_scope  {where(is_active: true)} 
  default_scope { where(organisation_id: Organisation.current_id) }
  scope :active, -> { where(is_active: true) }

  def manage_students(associate_students, organisation)
    curr_students = self.students.map(&:id)
    #removed_students = curr_students - associate_students
    #new_std = associate_students -  (curr_students & associate_students)
    #self.students.delete(organisation.students.where(id: removed_students))
    new_students = organisation.students.where(id: associate_students)
    new_students = new_students.where("id not in (?)", ([0]+ curr_students))
    self.students << new_students
  end

  def remove_student_from_class(associate_student, organisation)
    self.students.delete(organisation.students.where(id: associate_student))
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

  def daily_teaching_table_format
    table = [["Id", "Subject", "Chapter", "Points", "Date", "Sms Sent", "Divisions"]]

    self.daily_teaching_points.order(chapter_id: :desc,date: :desc).each_with_index do |dtp, index|
      table << ["#{index}", "#{dtp.subject.try(:name)}", "#{dtp.chapter.try(:name)}", "#{dtp.points}", "#{dtp.date.try(:to_date)}", "#{dtp.is_sms_sent}", "#{dtp.sub_classes}"]
    end
    table
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

  def subject_json(options={})
    options.merge({
                    id: id,
                    name: class_name,
                    o_subjects: subjects.optional.as_json
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
  
end
