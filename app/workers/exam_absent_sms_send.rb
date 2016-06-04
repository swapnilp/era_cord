class ExamAbsentSmsSend < Struct.new(:exam_arry)
  include SendingSms
  def perform
    send_sms(exam_arry)
  end
  
  def send_sms(exam_arry)
    exam_arry.each do |exam| 
      url = exam[0]
      message = exam[1]
      obj_id = exam[2]
      org_id = exam[3]
      number = exam[4]
      
      sms_sent = SmsSent.find_or_initialize_by({obj_type: "absent_exam", obj_id: obj_id, is_parent: true, organisation_id: org_id, number: number})
      unless sms_sent.id.present?
        deliver_sms(URI::encode(url))
      end
      #SmsSent.new({obj_type: "absent_exam", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id}).save
      sms_sent.message =  message
      sms_sent.save
    end
  end
end
#Delayed::Job.enqueue ExamAbsentSmsSend.new(Exam.last)

