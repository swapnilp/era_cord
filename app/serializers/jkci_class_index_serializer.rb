class JkciClassIndexSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :class_name, :students, :remaining_activity, :organisation_id, :is_student_verified, :created_at

  def students
    object.class_students_count
  end
  
  def remaining_activity
    object.pending_notifications.count
  end

  def created_at
    object.created_at.strftime("%Y-%m")
  end
  
end

