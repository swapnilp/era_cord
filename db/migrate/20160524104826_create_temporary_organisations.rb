class CreateTemporaryOrganisations < ActiveRecord::Migration
  def change
    create_table :temporary_organisations do |t|
      t.string :name, null: false, default: ""
      t.string :email, null: false, default: ""
      t.string :mobile, null: false, default: ""
      t.string :short_name, default: ""
      t.string :user_email, default: ""
      t.string :user_mobile, default: ""
      t.string :user_sms_code
      t.string :id_hash
      t.boolean :is_confirmed, default: false
      t.timestamps null: false
    end
  end
end
