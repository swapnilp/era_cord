class CreateContacts < ActiveRecord::Migration
  def change
    create_table :contacts do |t|
      t.string :name
      t.string :email
      t.text :mobile
      t.text :reason
      t.text :quote
      t.boolean :is_followed, default: false
      t.timestamps null: false
    end
  end
end
