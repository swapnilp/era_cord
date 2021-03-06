class UserLoginSerializer < ActiveModel::Serializer
  attributes :id, :email, :roles, :token, :organisation_id, :success, :is_manage_organiser, :name, :is_root, :logo_url, :verify_mobile, :mobile

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

  def is_manage_organiser
    object.has_role? :manage_organiser
  end

  def name
    object.organisation.name
  end
  
  def is_root
    object.organisation.root?
  end

  def success
    true
  end
  
  def logo_url
    object.organisation.logo_url || ""
  end
  def mobile
    if object.mobile.present? && !object.verify_mobile
      "#{object.mobile.first(2)}*****#{object.mobile.last(3)}"
    else
      object.mobile
    end
  end
  
end
