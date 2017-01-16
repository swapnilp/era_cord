class TeacherIntimateMailQueue < Struct.new(:user)
  #@queue = :mailer
  
  def perform
    send_mails(user)
  end

  def send_mails(user)
    TeacherMailer.intimate_teacher(user).deliver
  end

end
