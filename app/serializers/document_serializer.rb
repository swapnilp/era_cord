class DocumentSerializer < ActiveModel::Serializer
  #attributes :id, :name, :assign_to, :actions, :last_login, :standard_id, :is_selected
  attributes :id, :url, :name

  def url
    object.document.url
  end
  
  def name
    object.document_file_name
  end
end


