class ExamIndexSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected

  attributes :id, :name, :marks, :subject, :exam_date, :exam_type, :published_date, :status, :jkci_class_id, :is_point_added, :is_group, :self_organisation

  def subject
    object.is_group ? '' : object.std_subject_name
  end

  def exam_date
    object.exam_date.to_date
  end

  def published_date
    object.published_date.try(:to_date)
  end

  def status
    object.exam_status
  end

  def self_organisation
    scope[:current_organisation] == object.organisation_id
  end
  
end

