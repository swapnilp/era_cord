class OrganisationLoginSerializer < ActiveModel::Serializer
  attributes :id, :email, :token, :success, :name, :org_ids

  def email
    object.email
  end
  
  def token
    object.reset_auth_token!
  end


  def name
    object.name
  end

  def org_ids
    object.root.subtree_ids.join(',')
  end

  def success
    true
  end
end
