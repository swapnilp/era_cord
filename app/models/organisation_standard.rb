class OrganisationStandard < ActiveRecord::Base

  validates_uniqueness_of :standard_id, scope: :organisation_id
  default_scope { where(organisation_id: Organisation.current_id) }

  belongs_to :organisation
  belongs_to :standard

  belongs_to :assigned_organisation, class_name: "Organisation", foreign_key: "assigned_organisation_id"

end
