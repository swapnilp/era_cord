class ClassDtpDataSerializer < ActiveModel::Serializer
  attributes :id, :class_name,  :subjects

  has_many :subjects

  #this is for exam new 
end
