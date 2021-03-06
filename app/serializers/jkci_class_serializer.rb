class JkciClassSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :class_name, :subjects, :enable_class_sms, :enable_exam_sms, :has_time_table, :has_upgrade_batch, :is_student_verified,
  :is_current_active, :organisation_id

  def subjects
    object.subjects.map(&:name)
  end

  def has_time_table
    object.time_tables.where(sub_class_id: nil).present?
  end

  def has_upgrade_batch
    object.batch.next.present?
  end

end

