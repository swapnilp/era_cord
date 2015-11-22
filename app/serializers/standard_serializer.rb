class StandardSerializer < ActiveModel::Serializer
  attributes :id, :name, :stream

  def name
    object.name
  end
  
  def stream
    object.stream
  end
end

