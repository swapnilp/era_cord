class ClerkIntimationMail <  Struct.new(:user)
  def perform
    send_mails(user)
  end

  def send_mails(user)
    ClerkMailer.intimate_clerk(user).deliver
  end
end
