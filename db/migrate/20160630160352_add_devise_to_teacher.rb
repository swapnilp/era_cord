class AddDeviseToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :provider, :string
    add_column :teachers, :tokens, :text
    add_column :teachers, :token_expires_at, :timestamp
    add_column :teachers, :encrypted_password, :string, null: false, default: ""
    
    ## Recoverable
                                                                                                        
    add_column :teachers, :reset_password_token, :string
    add_column :teachers, :reset_password_sent_at, :datetime
    
    ## Rememberable
    add_column :teachers, :remember_created_at, :datetime
    
    ## Trackable
    add_column :teachers, :sign_in_count, :integer, default: 0, null: false
    add_column :teachers, :current_sign_in_at, :datetime
    add_column :teachers, :last_sign_in_at, :datetime
    add_column :teachers, :current_sign_in_ip, :string
    add_column :teachers, :last_sign_in_ip, :string

    add_column :teachers, :enabled_login, :boolean, default: false
    
    add_index :teachers, :reset_password_token, unique: true
  end
end
