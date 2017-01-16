class TeacherRemoveMailQueue < Struct.new(:teacher)
  #@queue = :mailer
  
  def perform
    send_mails(teacher)
  end

  def send_mails(teacher)
    TeacherMailer.remove_teacher_mail(teacher).deliver
  end

end

