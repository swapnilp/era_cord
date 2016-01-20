class AddOrganisationIdToOffClass < ActiveRecord::Migration
  def change
    add_column :off_classes, :organisation_id, :integer
  end
end
