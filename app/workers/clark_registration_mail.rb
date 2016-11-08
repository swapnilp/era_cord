class ClarkRegistrationMail <  Struct.new(:user)
  def perform
    send_mails(user)
  end

  def send_mails(user)
    ClarkMailer.register_clark(user).deliver
  end
end
