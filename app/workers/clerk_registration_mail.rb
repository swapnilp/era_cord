class ClerkRegistrationMail <  Struct.new(:user)
  def perform
    send_mails(user)
  end

  def send_mails(user)
    ClerkMailer.register_clerk(user).deliver
  end
end
