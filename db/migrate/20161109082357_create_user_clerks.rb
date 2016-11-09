class CreateUserClerks < ActiveRecord::Migration
  def change
    create_table :user_clerks do |t|
      t.string :email, null: false
      t.references :organisation
      t.text :email_token
      t.text :mobile_token
      t.text :mobile, null: false
      
      t.timestamps null: false
    end
  end
end
