class ClassAbsentSms < Struct.new(:exam_arry)
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
      
      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "daily_teach_sms", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id, number: number}).save
    end
  end
end
#Delayed::Job.enqueue ClassAbsentSms.new(DailyTeachingPoint.last)
