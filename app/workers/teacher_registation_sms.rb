class TeacherRegistationSms < Struct.new(:teacher)
  include SendingSms
  def perform
    send_sms(teacher)
  end

  def send_sms(teacher)
    if teacher.present?
    
      url = teacher[0]
      message = teacher[1]
      obj_id = teacher[2]
      number = teacher[3]

      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "teacher_reg", obj_id: obj_id, message: message, is_parent: true, number: number}).save
    end
  end
end
#Delayed::Job.enqueue TeacherRegistationSms.new(DailyTeachingPoint.last)
