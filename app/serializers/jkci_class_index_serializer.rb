class JkciClassIndexSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :class_name, :students, :remaining_activity, :organisation_id, :is_student_verified

  def students
    object.class_students_count
  end
  
  def remaining_activity
    0
  end
  
end

