class ExamCatlogSerializer < ActiveModel::Serializer
  attributes :id, :student, :marks, :is_present, :absent_sms_sent, :is_ingored, :rank, :p_mobile, :student_id

  def student
    object.student.name
  end

  def p_mobile
    object.student.p_mobile
  end

  
end

