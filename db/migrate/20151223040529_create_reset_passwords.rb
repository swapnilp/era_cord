class CreateResetPasswords < ActiveRecord::Migration
  def change
    create_table :reset_passwords do |t|
      t.string :email, null: false
      t.text :token
      t.boolean :send_token, default: false
      t.timestamps null: false
    end
  end
end
