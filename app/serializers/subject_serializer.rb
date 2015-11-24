class SubjectSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :std_name

  def remaining_activity
    object.std_name
  end
  
end


