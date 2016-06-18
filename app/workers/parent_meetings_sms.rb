class ParentMeetingsSms < Struct.new(:students_arry)
  include SendingSms
  def perform
    send_sms(students_arry)
  end
  
  def send_sms(students_arry)
    students_arry.each do |student| 
      url = student[0]
      message = student[1]
      obj_id = student[2]
      org_id = student[3]
      student_id = student[4]
      number = student[5]
      
      sms_sent = SmsSent.find_or_initialize_by({obj_type: "meeting", obj_id: obj_id, is_parent: true, organisation_id: org_id, number: number, student_id: student_id})
      unless sms_sent.id.present?
        deliver_sms(URI::encode(url))
      end
      sms_sent.message =  message
      sms_sent.save
    end
  end
end
#Delayed::Job.enqueue ParentMeetingsSms.new(Exam.last)
