class ResetPassword < ActiveRecord::Base

  after_create :create_token
  
  def create_token
    new_token = Digest::SHA1.hexdigest([Time.now, rand].join)
    self.update_attributes({token: new_token})
    ForgotPasswordMailer.send_email(self).deliver
    #Delayed::Job.enqueue ForgotPasswordEmail.new(self)
  end
end
