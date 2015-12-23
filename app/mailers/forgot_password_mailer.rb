class ForgotPasswordMailer < ActionMailer::Base
  default from: "swapnil.patil04@gmail.com"
  
  def send_email(reset_password)
    @reset_password = reset_password
    mail(to: @reset_password.email, subject: 'Welcome to EraCord- Reset password')
  end
  
end


