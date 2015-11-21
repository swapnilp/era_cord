class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :provider, :string
    add_column :users, :uid, :string
    add_column :users, :tokens, :text
    add_column :users, :token_expires_at, :timestamp
  end
end
