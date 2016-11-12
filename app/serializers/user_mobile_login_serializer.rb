class UserMobileLoginSerializer < ActiveModel::Serializer
  attributes :id, :email, :token, :success, :name

  def email
    object.email
  end
  
  def token
    object.reset_auth_token!
  end

  def name
    object.organisation.name
  end
  
  def logo_url
    object.organisation.logo_url
  end

  def success
    true
  end
  
end
