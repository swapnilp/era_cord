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

  def organisation_json(options= {}, org = nil)
    if org.present?
      options.merge({
                      id: self.id,
                      name: std_name,
                      organisaitons: organisation_standards.map{|org_standard| org_standard.as_json({}, org)},
                      is_permission: org.root? || org.subtree_ids.include?(organisation_standards.where(is_assigned_to_other: false).first.organisation_id)
                    })
    else
      options.merge({
                      id: self.id,
                      name: std_name,
                      organisaitons: organisation_standards.as_json
                    })
    end
  end
  
end
