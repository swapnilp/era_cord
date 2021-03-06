class StudentShowSerializer < ActiveModel::Serializer
  attributes :id, :name, :batch, :standard, :parent_name, :p_mobile, :mobile, :class_names, :roll_number, :enable_sms, :remaining_fee, :subjects, :hostel_id, :hostel, :image_url
  
  def name
    object.name
  end
  
  def batch
    object.batch.name
  end

  def standard
    object.standard.try(:name)
  end

  def class_names
    object.jkci_classes.map(&:class_name).join(", ")
  end

  def remaining_fee
    object.total_remaining_fees.sum
  end

  def subjects
    object.subjects.map(&:std_name)
  end

  def roll_number
    object.try(:roll_number)
  end

  def hostel
    object.hostel.try(:name)
  end

  def image_url
    object.photo_url(scope[:image]) #"https://s3.amazonaws.com/Eracord/Eracord/images/man.png"
  end

end

