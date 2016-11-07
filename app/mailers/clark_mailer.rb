class ClarkMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_clark(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EraCord- Create eraCord account')
  end

  def intimate_clark(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EraCord- Intimate eraCord account')
  end
  
end

