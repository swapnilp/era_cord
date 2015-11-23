class SubOrganisationSerializer < ActiveModel::Serializer
  attributes :id, :name, :mobile, :standards, :actions, :email

  
  def actions
    true 
  end
  
  def standards
    'new one '
  end
  
end

