class DailyTeachingPoint < ActiveRecord::Base
  
  belongs_to :jkci_class
  belongs_to :teacher
  has_many :class_catlogs
  #has_many :students, through: :class_catlogs
  belongs_to :subject
  belongs_to :chapter
  belongs_to :chapters_point
  has_many :notifications, -> {where("notifications.object_type like ?", 'DailyTeaching_point')}, :foreign_key => :object_id 
  
  default_scope { where(organisation_id: Organisation.current_id) }
  scope :chapters_points, -> { where("chapter_id is not ?", nil) }
  #after_save :add_current_chapter
  after_save :check_off_classes
 

  def check_off_classes
    self.jkci_class.off_classes.where(date: self.date.to_date, subject_id: self.subject_id).destroy_all
  end
  
  def absent_count
    students_count = self.class_catlogs.where(is_present: false).count
    students_count.zero? ? "" : " #{students_count}"
  end

  def role_notification(user)
    user_roles = user.roles.select([:name]).map(&:name).map(&:to_sym)
    notification_roles = NOTIFICATION_ROLES.slice(*user_roles).values.flatten
    notifications.where(actions: notification_roles)
    #self.notifications
  end

  def chapter_points
    if self.chapter.present? && self.chapters_point_id.present?
      self.chapter.chapters_points.where(id: chapters_point_id.split(',').map(&:to_i)).map(&:name).join(', ')
    else
      return ""
    end
  end

  def class_students
    #Student.where(std: std, is_active: true)
    if sub_classes.present?
      self.jkci_class.sub_classes_students(self.sub_classes.split(',').map(&:to_i), self.subject) rescue []
    else 
      self.subject.students.joins(:class_students).where("class_students.jkci_class_id = ?", self.jkci_class_id) rescue []
    end
  end

  def students 
    self.class_students
  end

  #def present_students
    #self.students.where("class_catlogs.is_present is not false")
  #end

  def verify_presenty
    self.update_attributes({verify_absenty: true})
    #self.present_students.update_all({last_present: Time.now})#.map(&:update_presnty)
  end
  
  def exams
    Exam.where("daily_teaching_points like '%?%'", self.id)
  end

  def create_catlog
    class_students.each do |student|
      self.class_catlogs.build({student_id: student.id, date: self.date, jkci_class_id: self.jkci_class_id, organisation_id: self.organisation_id}).save
    end
  end

  def fill_catlog(absent_list,  date)
    #self.update_attributes({is_fill_catlog: true, verify_absenty: false})
    #class_catlogs.where(student_id: present_list).update_all({is_present: false, date: date})
    #class_catlogs.where("student_id not in (?)", present_list).update_all({is_present: true, date: date})
    class_catlogs.where("student_id not in (?)", [0] << absent_list).destroy_all
    absent_students = self.students.where(id: absent_list)
    absent_students.each do |student|
      #self.class_catlogs.build({student_id: student.id, date: self.date, jkci_class_id: self.jkci_class_id, organisation_id: self.organisation_id}).save
      class_catlog = self.class_catlogs.find_or_initialize_by({student_id: student.id, jkci_class_id: self.jkci_class_id, organisation_id: self.organisation_id})
      class_catlog.is_present = false
      class_catlog.save
    end
  end

  def make_absent(absent_student)
    absent_students = self.students.where(id: absent_student)
    absent_students.each do |student|
      #self.class_catlogs.build({student_id: student.id, date: self.date, jkci_class_id: self.jkci_class_id, organisation_id: self.organisation_id}).save
      class_catlog = self.class_catlogs.find_or_initialize_by({student_id: student.id, jkci_class_id: self.jkci_class_id, organisation_id: self.organisation_id})
      class_catlog.is_present = false
      class_catlog.date = class_catlog.daily_teaching_point.date.to_date
      class_catlog.save
      self.update_attributes({verify_absenty: false})
    end
  end

  def remove_absent(absent_student)
    class_catlogs.where("student_id in (?)", [0] << absent_student).destroy_all
    self.update_attributes({verify_absenty: false})
  end

  def add_current_chapter
    self.jkci_class.update_attributes({current_chapter_id: self.chapter_id})
  end

  def publish_absenty
    if self.jkci_class.enable_class_sms
      Delayed::Job.enqueue ClassAbsentSms.new(self.absenty_message_send) 
      self.update_attributes({is_sms_sent: true}) 
    end
  end

  def absenty_message_send
    url_arry = []
    self.class_catlogs.includes([:jkci_class, :student]).only_absents.each_with_index do |class_catlog, index|
      if class_catlog.student.enable_sms
        message = "We regret to convey you that your son/daughter #{class_catlog.student.short_name} is absent for #{self.jkci_class.class_name} lectures.Plz contact us. JKSai!!"
        url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=eracod&dmobile=#{class_catlog.student.sms_mobile}&message=#{message}"
        unless class_catlog.sms_sent
          url_arry << [url, message, class_catlog.id, self.organisation_id, class_catlog.student.sms_mobile]
          #class_catlog.update_attributes({sms_sent: true})
        end
      end
    end
    url_arry
  end

  def as_json(options= {}, org = nil)
    if org.present?
      options.merge({
                      id: id,
                      date: date.to_date,
                      subject: subject.try(:name),
                      chapter: chapter.try(:name),
                      points: 'asdads',
                      absents: class_catlogs_count,
                      is_sms_sent: is_sms_sent,
                      jkci_class: jkci_class.class_name,
                      verify_absenty: verify_absenty,
                      enable_sms: jkci_class.enable_class_sms,
                      self_organisation: organisation_id == org.id
                    })
    else
      options.merge({
                      id: id,
                      date: date.to_date,
                      subject: subject.try(:name),
                      chapter: chapter.try(:name),
                      points: 'asdads',
                      absents: class_catlogs_count,
                      is_sms_sent: is_sms_sent,
                      jkci_class: jkci_class.class_name,
                      verify_absenty: verify_absenty,
                      enable_sms: jkci_class.enable_class_sms
                    })
    end
  end

  def show_json(options = {})
    options.merge({
                    id: id,
                    date: date.strftime("%d %B %Y"),
                    subject_id: subject_id,
                    chapter_id: chapter_id,
                    chapters_point_id: chapters_point_id.split(',').map(&:to_i),
                    jkci_class: jkci_class.class_name,
                    subject: subject.std_name
                  })
  end

  def edit_json(options= {})
    options.merge({
                    id: id,
                    date: date,
                    subject_id: subject_id,
                    chapter_id: chapter_id,
                    chapters_point_id: chapters_point_id.split(',').map(&:to_i),
                    jkci_class: jkci_class.class_name,
                    subject: subject.std_name
                  })
  end

  
end
