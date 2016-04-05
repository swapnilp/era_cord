class FeeAccountSms < Struct.new(:student_fee)
  include SendingSms
  def perform
    send_sms(student_fee)
  end

  def send_sms(student_fee)
    if student_fee.present?
    
      url = student_fee[0]
      message = student_fee[1]
      obj_id = student_fee[2]
      org_id = student_fee[3]

      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "student_fee", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id}).save
    end
  end
end

