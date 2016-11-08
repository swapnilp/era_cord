class UserOtpSms < Struct.new(:user)
  include SendingSms
  def perform
    send_sms(user)
  end

  def send_sms(user)
    if user.present?
    
      url = user[0]
      message = user[1]
      obj_id = user[2]
      org_id = user[3]
      number = user[4]

      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "user_otp", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id, number: number}).save
    end
  end
end
#Delayed::Job.enqueue UserOtpSms.new(DailyTeachingPoint.last)
