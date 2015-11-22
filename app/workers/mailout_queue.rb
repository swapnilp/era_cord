class MailoutQueue
  @queue = :mailer
  def self.perform(exam, student)
    UserMailer.send_result(exam, student).deliver
  end
end
