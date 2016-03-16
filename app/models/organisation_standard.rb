class OrganisationStandard < ActiveRecord::Base

  validates_uniqueness_of :standard_id, scope: :organisation_id
  default_scope { where(organisation_id: Organisation.current_id) }

  belongs_to :organisation
  belongs_to :standard

  belongs_to :assigned_organisation, class_name: "Organisation", foreign_key: "assigned_organisation_id"
  
  after_create :create_organisation_calss
  
  def create_organisation_calss
  end

  def as_json(options = {}, org  = nil)
    options.merge({
                    id: id,
                    standard_id: standard_id,
                    organisation_id: organisation_id,
                    organisation_name: organisation.try(:name),
                    is_active: is_active,
                    is_assigned_to_other: is_assigned_to_other,
                    assigned_organisation_id: assigned_organisation_id,
                    is_parent_organisation: organisation.root?,
                    is_children: org.present? ? org.children.exists?(id: self.organisation_id) : nil
                  })
    
  end

end
