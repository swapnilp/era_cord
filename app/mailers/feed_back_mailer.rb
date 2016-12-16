class FeedBackMailer < ActionMailer::Base
  default from: "admin@eracord.com"
  
  def send_feedback(feed_back)
    @feedback = feed_back
    mail(to: 'admin@eracord.com', subject: "Eracord - Feedback Mail #{@feedback.medium}", cc: "nileshgorle@gmail.com")
  end
end
