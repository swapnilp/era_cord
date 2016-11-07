class ClarkIntimationMail <  Struct.new(:user)
  def perform
    send_mails(user)
  end

  def send_mails(user)
    ClarkMailer.intimate_clark(user).deliver
  end
end
