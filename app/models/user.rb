class User < ActiveRecord::Base
  PASSWORD_REGEX = /\A(?=.*[A-Z])(?=.*[0-9])(?=.*[a-z]).{8,}\z/
  TOKEN_SECRET = Rails.application.secrets[:secret_key_base]
  TOKEN_EXPIRE_TIME = 1.days#2.hours
  
  rolify
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable,
          :rememberable, :trackable, :authentication_keys => [:login, :organisation_id]#, request_keys: [:organisation_id]
  attr_accessor :login

  has_many :students
  belongs_to :teacher, foreign_key: :email, primary_key: :email
  
  belongs_to :organisation
  
  validates :organisation_id, :presence => true#, :email => true, scope: :organisation_id

  
  validates_uniqueness_of :email, :scope => [:organisation_id, :role], :case_sensitive => false, :allow_blank => true#, :if => true
  validates_presence_of :email
  validates_format_of :email, :with => Devise.email_regexp, :allow_blank => true, :if => :email_changed?
  validates_presence_of :password, :on=>:create , :if => proc{ |u| !u.encrypted_password.present? }
  validates_confirmation_of :password, :if => proc{ |u| !u.encrypted_password.present? }#,  #:on=>[:create, :update]
  validates_length_of :password, :within => Devise.password_length, :allow_blank => true, :if => proc{ |u| !u.encrypted_password.present? }

  scope :clarks, -> {where(role: 'clark')}

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

  
  def check_not_registered
    Organisaiton.where("email_code != ?", nil)
  end

  def reset_password(new_password, new_password_confirmation)
    self.password = new_password
    self.password_confirmation = new_password_confirmation
    
    if respond_to?(:after_password_reset) && valid?
      ActiveSupport::Deprecation.warn "after_password_reset is deprecated"
      after_password_reset
    end
    save
  end
  
  def self.find_for_database_authentication(warden_conditions)
    conditions = warden_conditions.dup
    if (login = conditions.delete(:login)) && (org = conditions.delete(:organisation_id)) 
      where(conditions.to_h).where(["(lower(username) = :value OR lower(email) = :value) AND organisation_id = :org", { :value => login.downcase, org: org }])
    else
      where(conditions.to_h)
    end
  end

  def self.check_duplicate(warden_conditions, password)
    conditions = warden_conditions.dup
    users = where(conditions.to_h).select{|u| u.valid_password? password}
    return users
  end

  def self.get_teachers_organisations(warden_conditions)
    conditions = warden_conditions.dup
    users = where(conditions.to_h).select{|u| u.has_role?(:teacher)}
    return users
  end

  def self.send_reset_password_instructions(warden_conditions)
    conditions = warden_conditions.dup
    user = where(conditions.to_h).first
    if user
      ResetPassword.new({email: user.email, object_type: "User"}).save
      return true
    else
      return false
    end
  end

  def after_database_authentication
    self.organisation.update_attributes({last_signed_in: Time.now}) if self.organisation.present?
  end 

  def set_last_sign_in_at
    User.where(email: self.email, last_sign_in_at: nil).update_all({last_sign_in_at: Time.now})
  end

  def active_for_authentication?
    super && is_enable
  end

  def add_organiser_roles
    u_roles = ["admin", "clark", "verify_exam", "exam_conduct", "verify_exam_absenty", "add_exam_result", "verify_exam_result", "publish_exam", "create_exam", "add_exam_absenty", "create_daily_teach", "add_daily_teach_absenty", "verify_daily_teach_absenty", "publish_daily_teach_absenty", "manage_class_sms", "organisation", "add_student", "manage_student_subject", "manage_class_student", "manage_roll_number", "manage_class", "manage_organiser", "toggle_student_sms", "download_class_report"]
    if organisation.root?
      u_roles << 'accountant'
    end
    u_roles.each do |u_role|
      self.add_role u_role.to_sym 
    end
  end
  
  def add_clark_roles
    ["create_exam", "verify_exam", "exam_conduct", "add_exam_absenty", 
     "add_exam_result", "publish_exam", "create_daily_teach", "add_daily_teach_absenty", 
     "verify_daily_teach_absenty"].each do |u_role|
      self.add_role u_role.to_sym 
    end
    
  end
  
  def add_teacher_roles
    ["verify_exam", "exam_conduct", "verify_exam_absenty", "add_exam_result", "verify_exam_result", "publish_exam", 
     "create_exam", "add_exam_absenty", "create_daily_teach", "add_daily_teach_absenty", "verify_daily_teach_absenty", 
     "publish_daily_teach_absenty", "teacher"].each do |u_role|
      self.add_role u_role.to_sym 
    end
  end

  def manage_clark_roles(new_roles, is_root = false)
    self.roles = []
    new_roles = new_roles.split(',')
    new_roles.each do |u_role| 
      if is_root
        self.add_role u_role.to_sym if ADMIN_CLARK_ROLES.include?(u_role) 
      else
        self.add_role u_role.to_sym if CLARK_ROLES.include?(u_role) 
      end
    end
    self.add_role :clark
    self.update(token_expires_at: nil)
  end

  def self.create_clark(user_params, organisation)
    check_user = User.where(email: user_params[:email]).first
    if check_user.present?
      new_user = check_user.dup
      new_user.role = 'clark'
      new_user.add_clark_roles
      new_user.organisation_id = organisation.id
      if new_user.save
        Delayed::Job.enqueue ClarkIntimationMail.new(new_user) 
        is_save = true
      else
        is_save = false
      end
    else
      new_user = organisation.users.clarks.build(user_params)
      new_user.password = CLARK_DEFAULT_PASSWORD
      new_user.role = 'clark'
      if new_user.save
        is_save = true
        new_user.add_role :clark
        new_user.add_clark_roles
        #reset password link send
        p '@@@@@@@@@@@@ reset password link send'
      else
        is_save = false
      end
    end
    return is_save, new_user
  end
  
  def admin?
    return role == 'admin'
  end

  def organiser?
    return role == 'organisation'
  end

  def staff?
    return role == 'staff'
  end

  def clark?
    return role == 'clark'
  end

  def parent?
    return role == 'parent'
  end

  def login=(login)
    @login = login
  end

  def login
    @login || self.username || self.email
  end

  def token_fields
    { email: email, organisation_id: organisation_id}
  end

  def organisation_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: organisation_id,
                    organisation_name: organisation.name,
                    role: role
                  })
  end

  def clark_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: organisation_id,
                    email: email,
                    is_enable: is_enable, 
                    is_active: last_sign_in_at.nil?
                  })
  end
end
