class ExamSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :name, :marks, :subject, :exam_date, :exam_type, :published_date, :jkci_class_id, :is_group, :verify_result, :verify_absenty, :create_verification, :divisions, :is_completed, :is_result_decleared, :conducted_by, :jkci_class, :duration, :documents

  has_many :documents

  def subject
    object.subject.std_name
  end

  def jkci_class
    object.jkci_class.class_name
  end
  
  def exam_date
    object.exam_date.to_date
  end

  def published_date
    object.published_date.try(:to_date)
  end

  def divisions
    object.jkci_class.sub_classes.where(id: object.sub_classes).map(&:name).join(', ')
  end
  
end

