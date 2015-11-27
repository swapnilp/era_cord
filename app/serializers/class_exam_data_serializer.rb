class ClassExamDataSerializer < ActiveModel::Serializer
  attributes :id, :class_name, :sub_classes, :subjects

  has_many :subjects
  has_many :sub_classes

  #this is for exam new 
end
