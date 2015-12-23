class ForgotPasswordEmail < Struct.new(:forgot_password)
  #@queue = :mailer
  
  def perform
    send_mails(forgot_password)
  end

  def send_mails(forgot_password)
    ForgotPasswordMailer.send_email(forgot_password).deliver
  end

end
