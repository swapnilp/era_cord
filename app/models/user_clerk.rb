class UserClerk < ActiveRecord::Base
  belongs_to :organisation

  after_create :generate_email_code
  
  def generate_email_code
    e_code = self.email_token || (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    
    charset = %w{ 2 3 4 6 7 9 0 1}
    m_code = self.mobile_token || (0...6).map{ charset.to_a[rand(charset.size)] }.join
    
    update_attributes({email_token: e_code, mobile_token: m_code})
    self.send_generated_code
  end

  def send_generated_code
    Delayed::Job.enqueue ClerkMailQueue.new(self)
    Delayed::Job.enqueue ClerkRegistationSms.new(self.clerk_sms_message)
  end

  def resend_invitation
    Delayed::Job.enqueue ClerkMailQueue.new(self)
  end

  def resend_sms
    Delayed::Job.enqueue ClerkRegistationSms.new(self.clerk_sms_message)
  end

  def clerk_sms_message
    message = "One Time Password for mobile number verification of user #{self.email} is #{self.mobile_token}. Please do not share OTP to anyone for security reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=eracod&dmobile=91#{self.mobile}&message=#{message}"
    url_arry = [url, message, self.id, self.mobile]
  end

  
  def clerk_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: organisation_id,
                    email: email,
                    mobile: mobile
                  })
  end
end
