class GTeacherLoginSerializer < ActiveModel::Serializer
  attributes :id, :email, :token, :success, :name

  def email
    object.email
  end
  
  def token
    object.reset_auth_token!
  end


  def name
    object.name
  end

  def success
    true
  end
end
