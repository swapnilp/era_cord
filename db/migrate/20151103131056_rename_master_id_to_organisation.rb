class RenameMasterIdToOrganisation < ActiveRecord::Migration
  def change
    rename_column :organisations, :master_organisation_id, :parent_id
  end
end
