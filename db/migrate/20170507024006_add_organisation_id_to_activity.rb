class AddOrganisationIdToActivity < ActiveRecord::Migration
  def change
    add_column :activities, :organisation_id, :integer
  end
end
