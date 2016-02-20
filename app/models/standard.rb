class Standard < ActiveRecord::Base
  has_many :subjects
  has_many :students
  has_many :jkci_classes
  has_many :organisation_standards
  
  belongs_to :assigned_organisation, class_name: "Organisation", foreign_key: "assigned_organisation_id"
  
  scope :active, -> {where(is_active: true)}

  def std_name
    "#{name}-#{stream}"
  end

  def to_json(options= {})
    options.merge({
                    id: self.id,
                    name: std_name
                  })
  end


  def as_json(options= {})
    options.merge({
                    id: self.id,
                    name: std_name
                  })
  end

  def organisation_json(options= {})
    options.merge({
                    id: self.id,
                    name: std_name,
                    organisaitons: organisation_standards.as_json
                  })
  end
  
end
