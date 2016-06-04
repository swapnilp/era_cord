class ExamResultSmsSend < Struct.new(:exam_arry)
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
      student_id = exam[4]
      number = exam[5]
      
      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "exam_result", obj_id: obj_id, message: message, is_parent: true, organisation_id: org_id, student_id: student_id, number: number}).save
    end

  end
end
#Delayed::Job.enqueue ExamResultSmsSend.new(Exam.last)
