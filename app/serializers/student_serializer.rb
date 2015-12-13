class StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :batch, :standard, :parent_name, :p_mobile, :mobile, :subjects, :class_names, :roll_number

  
  def name
    object.name
  end
  
  def batch
    object.batch.name
  end

  def standard
    object.standard.try(:name)
  end

  def subjects
    object.subjects.map(&:std_name).join(', ')
  end

  def class_names
    object.jkci_classes.map(&:class_name).join(", ")
  end

  def roll_number
    object.try(:roll_number)
  end

end

