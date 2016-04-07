class Batch < ActiveRecord::Base

  has_many :jkci_classes
  has_many :students
  #default_scope  { where(is_active: true) } 
  scope :active, -> {where(is_active: true).order("id DESC")}

  def next
    self.class.where("id > ?", id).first
  end

  def previous
    self.class.where("id < ?", id).last
  end
  
  def as_json(options = {})
    options.merge({
                    id: id,
                    name: name,
                    std: std,
                    is_active: is_active
                  })
    
  end
end
