class ParentsMeeting < ActiveRecord::Base
  acts_as_organisation
  
  has_many :meetings_students
  belongs_to :jkci_class
  

  belongs_to :batch

  def create_meetings_students(org, students_list = "")
    Student.select([:id, :p_mobile]).where(id: students_list.split(',')).each do |m_student|
      self.meetings_students.find_or_initialize_by({student_id: m_student.id, mobile: m_student.p_mobile, organisation_id: org.id}).save
    end
  end

  def publish_metting
    Delayed::Job.enqueue ParentMeetingsSms.new(sms_arry(org))
  end

  def sms_arry(org)
    url_arry = []
    if org.is_send_message
      self.meetings_students.includes([:student]).each_with_index do |meeting_student, index|
        message = "Dear Parent, kindly attend the Parent-Teacher Meeting scheduled on #{self.date.strftime("%d %b %Y @%I:%M%p")} - #{org.name}.#{org.short_name || 'eraCord'}"
        message = message.truncate(159)
        url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=eracod&dmobile=#{meeting_student.student.sms_mobile}&message=#{message}"
        url_arry << [url, message, meeting_student.id, self.organisation_id, meeting_student.student_id, meeting_student.student.sms_mobile]
      end
    end
    url_arry
  end

  def self.my_organisation(org_id)
    where(organisation_id: org_id)
  end

  def as_json(options= {})
    options.merge({
                    id: id,
                    agenda: agenda,
                    date: date.strftime("%d %b %Y %I:%M %p"),
                    contact_person: contact_person,
                    sms_sent: sms_sent,
                    jkci_class_id: jkci_class_id
                  })
    
  end
  
  
end
