class ActivationSms < Struct.new(:student)
  include SendingSms
  def perform
    send_sms(student)
  end
  
  def send_sms(student)
    if student.present?
      url = student[0]
      message = student[1]
      obj_id = student[2]
      org_id = student[3]
      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "activation_sms", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id}).save
    end
  end
end
#Delayed::Job.enqueue ActivationSms.new(student)
