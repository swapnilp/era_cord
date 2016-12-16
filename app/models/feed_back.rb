class FeedBack < ActiveRecord::Base
  
  after_create :send_mail

  def send_mail
    Delayed::Job.enqueue FeedbackQueue.new(self)
  end
end
