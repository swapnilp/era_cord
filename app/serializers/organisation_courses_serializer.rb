class OrganisationCoursesSerializer < ActiveModel::Serializer
  attributes :id, :name, :assign_to, :actions, :last_login

  def name
    object.standard.std_name
  end
  
  def assign_to
    object.assigned_organisation.present? ? object.assigned_organisation.name : ''
  end
  
  def actions
    object.assigned_organisation.present?
  end
  
  def last_login
    if object.assigned_organisation.present?
      distance_of_time_in_words(standard.assigned_organisation.try(:last_signed_in), Time.now)
    else
      ''
    end
  end

  
end

