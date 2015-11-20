class AddSubOrganisationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :master_organisation_id, :integer, default: nil
    add_column :organisations, :sub_organisations_count, :integer, default: 0
  end
end
