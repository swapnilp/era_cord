class StudentSerializer < ActiveModel::Serializer
  attributes :id, :name, :batch, :standard, :parent_name, :p_mobile

  def name
    object.name
  end
  
  def batch
    object.batch.name
  end

  def standard
    object.standard.name
  end

end

