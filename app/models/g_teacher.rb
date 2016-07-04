class GTeacher < ActiveRecord::Base
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}\z/
  TOKEN_SECRET = Rails.application.secrets[:secret_key_base]
  TOKEN_EXPIRE_TIME = 1.days#2.hours
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :recoverable, :rememberable, :trackable, :validatable, :authentication_keys => [:email]


  has_many :teachers

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
end
