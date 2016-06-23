class AddDeviseToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :encrypted_password, :string, null: false, default: "eracoed@123"

    ## Recoverable
    add_column :organisations, :reset_password_token, :string
    add_column :organisations, :reset_password_sent_at, :datetime

    ## Rememberable
    add_column :organisations, :remember_created_at, :datetime

    ## Trackable
    add_column :organisations, :sign_in_count, :integer, default: 0, null: false
    add_column :organisations, :current_sign_in_at, :datetime
    add_column :organisations, :last_sign_in_at, :datetime
    add_column :organisations, :current_sign_in_ip, :string
    add_column :organisations, :last_sign_in_ip, :string
    
    add_index :organisations, :email,                unique: true
    add_index :organisations, :reset_password_token, unique: true
  end
end
