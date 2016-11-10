class ClerkMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def registation_clerk(user_clerk)
    @user = user_clerk
    mail(to: @user.email, subject: 'Welcome to EraCord- Create eraCord account')
  end

  def intimate_clerk(user)
    @user = user
    mail(to: @user.email, subject: 'Welcome to EraCord- Intimate eraCord account')
  end
end

