class TemporaryOrganisation < ActiveRecord::Base
  
  validates :name, presence: true
  validates :email, presence: true
  validates :mobile, presence: true
  validates_format_of :mobile, :with =>  /\A\d{10}\z/ , :message => "only 10 digit numbers are allowed"

  validates :short_name, presence: true

  
  def generate_code(user)
    e_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    charset = %w{ 2 3 4 6 7 9 0 1}
    m_code = (0...6).map{ charset.to_a[rand(charset.size)] }.join
    update_attributes({id_hash: e_code, user_sms_code: m_code})
    self.send_generated_code(user)
  end


  def send_generated_code(user)
    Delayed::Job.enqueue OrganisationRegistationSms.new(organisation_sms_confirmation(user))
  end

  def organisation_sms_confirmation(user)
    message = "One Time Password for mobile number verification of user #{self.name} is #{self.user_sms_code}. Please do not share OTP to anyone for security reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=eracod&dmobile=91#{user.mobile}&message=#{message}"
    url_arry = [url, message, self.id, self.id, user.mobile]
  end

  def create_organisation
    organisation = Organisation.new({name: self.name, mobile: self.mobile, email: self.email, short_name: self.short_name})
    if organisation.save
      self.update_attributes({is_confirmed: true})
      return true
    else
      return false
    end
  end
end
