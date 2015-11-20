class BatchResult < ActiveRecord::Base
  has_many :results
  
  has_many :published_results, -> {where(is_published: true)}, class_name: 'Result'
  scope :published, -> {where(is_published: true).order("id DESC")}


  
end
