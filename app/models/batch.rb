class Batch < ActiveRecord::Base

  has_many :jkci_classes
  has_many :students
  default_scope  { where(is_active: true) } 
  scope :active, -> {where(is_active: true).order("id DESC")}
end
