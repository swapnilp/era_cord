class ClerkRegistationSms < Struct.new(:user_clerk)
  include SendingSms
  def perform
    send_sms(user_clerk)
  end

  def send_sms(user_clerk)
    if user_clerk.present?
    
      url = user_clerk[0]
      message = user_clerk[1]
      obj_id = user_clerk[2]
      number = user_clerk[3]

      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "clerk_reg", obj_id: obj_id, message: message, is_parent: true, number: number}).save
    end
  end
end
#Delayed::Job.enqueue TeacherRegistationSms.new(DailyTeachingPoint.last)
