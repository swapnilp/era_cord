class JkciClassSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :class_name, :subjects, :enable_class_sms, :enable_exam_sms

  def subjects
    object.subjects.map(&:name).join(' | ')
  end
  
end

