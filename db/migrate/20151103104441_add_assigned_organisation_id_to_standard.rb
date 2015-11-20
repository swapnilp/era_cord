class AddAssignedOrganisationIdToStandard < ActiveRecord::Migration
  def change
    add_column :organisation_standards, :assigned_organisation_id, :integer
  end
end
