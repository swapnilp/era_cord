class GTeacher < ActiveRecord::Base
  has_many :teachers

  #after_create :generate_email_code

  def generate_email_code(org)
    user = org.all_users.where(email: self.email).first
    if user.present?
      user.add_role :teacher
    else
      e_code = (0...50).map { ('a'..'z').to_a[rand(26)] }.join
      m_code = (0...7).map { ('a'..'z').to_a[rand(26)] }.join
      update_attributes({email_code: e_code, mobile_code: m_code})
      self.send_generated_code
    end
  end

  def send_generated_code
    Delayed::Job.enqueue TeacherMailQueue.new(self)
    Delayed::Job.enqueue TeacherRegistationSms.new(teacher_sms_message)
  end


  def name
    "#{first_name} #{last_name}"
  end

  def teacher_sms_message
    message = "One time password is #{self.mobile_code}  for #{self.name} registation on EraCord. Please do not share OTP to any one for securiety reason."
    url = "https://www.txtguru.in/imobile/api.php?username=#{SMSUNAME}&password=#{SMSUPASSWORD}&source=update&dmobile=91#{self.mobile}&message=#{message}"
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
