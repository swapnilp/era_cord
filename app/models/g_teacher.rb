class GTeacher < ActiveRecord::Base
  has_many :teachers

  #after_create :generate_email_code

  def generate_email_code(org)
    e_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
    m_code = (0...7).map { ('a'..'z').to_a[rand(26)] }.join
    update_attributes({email_code: e_code, mobile_code: m_code})
    self.send_generated_code
  end

  def send_generated_code
    Delayed::Job.enqueue TeacherMailQueue.new(self)
    Delayed::Job.enqueue TeacherRegistationSms.new(teacher_sms_message)
  end

  def name
    "#{first_name} #{last_name}"
  end

  def not_registered
    list = []
    Teacher.unscoped.includes([:organisation, {organisation: :users}]).where(email: email).each do |teacher|
      if teacher.organisation.users.where(email: email).blank?
        list << teacher.organisation
      end
    end
    return list
  end

  def manage_registered_teacher(org)
    user = User.where(email: self.email).first
    if user.present?
      Teacher.unscoped.includes([:organisation, {organisation: :users}]).where(email: self.email).each do |teacher|
        o_user = teacher.organisation.all_users.where(email: self.email).first
        if o_user.nil?
          t_user = user.dup
          t_user.organisation_id = teacher.organisation_id
          t_user.role = 'teacher'
          t_user.mobile = teacher.mobile
          if (user.mobile == teacher.mobile && user.verify_mobile)
            t_user.verify_mobile = true
          end
          t_user.save(:validate => false)
          t_user.add_teacher_roles 
        else
          o_user.add_role :teacher
        end
      end
    else
      self.generate_email_code(org) if org.present?
    end
  end

  def teacher_sms_message
    message = "One time password is #{self.mobile_code}  for #{self.name} registation on EraCord. Please do not share OTP to any one for securiety reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=eracod&dmobile=91#{self.mobile}&message=#{message}"
    url_arry = [url, message, self.id, self.mobile]
  end

  def self.send_reset_password_instructions(warden_conditions)
    conditions = warden_conditions.dup
    g_teacher = where(conditions.to_h).first
    if g_teacher
      ResetPassword.new({email: g_teacher.email, object_type: "Teacher"}).save
      return true
    else
      return false
    end
  end
end
