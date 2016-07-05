class TeacherMailQueue < Struct.new(:g_teacher)
  #@queue = :mailer
  
  def perform
    send_mails(g_teacher)
  end

  def send_mails(g_teacher)
    TeacherMailer.registation_teacher(g_teacher).deliver
  end

end
