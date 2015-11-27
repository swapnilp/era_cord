class JkciClassIndexSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :class_name, :divisions, :remaining_activity

  def divisions
    object.sub_classes.count
  end
  
  def remaining_activity
    0
  end
  
end

