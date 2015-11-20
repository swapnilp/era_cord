class ExamAbsent < ActiveRecord::Base

  belongs_to :exam
  belongs_to :student

  def sms_send
  end

  def email_send
  end

end
