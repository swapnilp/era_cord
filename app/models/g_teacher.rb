class GTeacher < ActiveRecord::Base
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}\z/
  TOKEN_SECRET = Rails.application.secrets[:secret_key_base]
  TOKEN_EXPIRE_TIME = 1.days#2.hours
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:email]


  has_many :teachers

  after_create :generate_email_code

  def generate_email_code
    e_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    m_code = (0...7).map { ('a'..'z').to_a[rand(26)] }.join
    update_attributes({email_code: e_code, mobile_code: m_code})
    self.send_generated_code
  end

  def send_generated_code
    Delayed::Job.enqueue TeacherMailQueue.new(self)
    Delayed::Job.enqueue TeacherRegistationSms.new(teacher_sms_message)
  end

  def reset_auth_token!
    if token_expires_at.blank? || token_expires_at < Time.now
      update(token_expires_at: Time.now + TOKEN_EXPIRE_TIME)
    end
    JWT.encode token_fields, TOKEN_SECRET, 'HS256', exp: token_expires_at.to_i
  end

  def validate_auth_token(token)
    if token_expires_at.blank? || token_expires_at < Time.now
      update token_expires_at: nil
      return false
    end
    server_token = JWT.encode token_fields, TOKEN_SECRET, 'HS256', exp: token_expires_at.to_i
    JWT.secure_compare token, server_token
  end

  def token_fields
    { email: email}
  end

  def name
    "#{first_name} #{last_name}"
  end

  def teacher_sms_message
    message = "One time password is #{self.mobile_code}  for #{self.name} registation on EraCord. Please do not share OTP to any one for securiety reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.mobile}&message=#{message}"
    url_arry = [url, message, self.id, self.mobile]
  end
end
