class FeedbackQueue < Struct.new(:feed_back)
  #@queue = :mailer
  
  def perform
    send_mails(feed_back)
  end

  def send_mails(feed_back)
    FeedBackMailer.send_feedback(feed_back).deliver
  end

end
