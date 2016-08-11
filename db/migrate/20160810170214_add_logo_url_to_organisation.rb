class AddLogoUrlToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :logo_url, :string
  end
end
