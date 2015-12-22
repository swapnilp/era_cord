class UserLoginSerializer < ActiveModel::Serializer
  attributes :id, :email, :roles, :token, :organisation_id, :success

  def email
    object.email
  end
  
  def organisation_id
    object.organisation_id
  end

  def roles
    object.roles.map(&:name).join(',')
  end

  def token
    object.reset_auth_token!
  end

  def success
    true
  end

  
end
