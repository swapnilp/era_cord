class AddDeviceToGTeacher < ActiveRecord::Migration
  def change
    add_column :g_teachers, :provider, :string
    add_column :g_teachers, :device_id, :string
    add_column :g_teachers, :tokens, :text
    add_column :g_teachers, :token_expires_at, :timestamp
    add_column :g_teachers, :mpin, :integer
    add_column :g_teachers, :encrypted_password, :string, null: false, default: ""
    
    ## Recoverable
    
    add_column :g_teachers, :reset_password_token, :string
    add_column :g_teachers, :reset_password_sent_at, :datetime
    
    ## Rememberable
    
    add_column :g_teachers, :remember_created_at, :datetime
    
    ## Trackable
    
    add_column :g_teachers, :sign_in_count, :integer, default: 0, null: false
    add_column :g_teachers, :current_sign_in_at, :datetime
    add_column :g_teachers, :last_sign_in_at, :datetime
    add_column :g_teachers, :current_sign_in_ip, :string
    add_column :g_teachers, :last_sign_in_ip, :string
    
    add_index :g_teachers, :email,                unique: true
    add_index :g_teachers, :reset_password_token, unique: true
    
  end
end
