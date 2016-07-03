class CreateGTeachers < ActiveRecord::Migration
  def change
    create_table :g_teachers do |t|
      t.string :email
      t.string :first_name
      t.string :last_name
      t.string :mobile
      t.string :address
      t.timestamps null: false
    end
  end
end
