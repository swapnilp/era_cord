class GroupExamDataSerializer < ActiveModel::Serializer
  attributes :id, :class_name, :subjects, :sub_classes


  def class_name
    object.jkci_class.class_name
  end
  
  def subjects
    object.jkci_class.subjects.as_json
  end

  def sub_classes
    object.sub_classes.present? ? object.jkci_class.get_sub_classes(object.sub_classes.split(',')) : nil
  end
  #has_many :subjects

  #this is for exam new 
end
