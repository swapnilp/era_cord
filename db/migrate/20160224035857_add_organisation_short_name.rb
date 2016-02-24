class AddOrganisationShortName < ActiveRecord::Migration
  def change
    add_column :organisations, :short_name, :string
  end
end
