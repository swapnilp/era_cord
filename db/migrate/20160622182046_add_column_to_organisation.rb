class AddColumnToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :provider, :string
    add_column :organisations, :uid, :string
    add_column :organisations, :tokens, :text
    add_column :organisations, :token_expires_at, :timestamp
  end
end
