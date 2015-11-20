class AddIsAssignedToOrganisationStandard < ActiveRecord::Migration
  def change
    add_column :organisation_standards, :is_assigned_to_other, :boolean, default: false
  end
end
