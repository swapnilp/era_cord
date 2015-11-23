class OrganisationCoursesSerializer < ActiveModel::Serializer
  include ActionView::Helpers::DateHelper
  attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected

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
      object.assigned_organisation.try(:last_signed_in).nil? ? 'Never' : distance_of_time_in_words(object.assigned_organisation.try(:last_signed_in), Time.now) 
    else
      ''
    end
  end

  def is_selected
    false
  end

  
end

