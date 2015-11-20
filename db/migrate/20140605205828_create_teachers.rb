class CreateTeachers < ActiveRecord::Migration
  def change
    create_table :teachers do |t|
      t.references :subject
      t.string :first_name
      t.string :last_name
      t.string :mobile
      t.string :email
      t.text :address
      t.timestamps
    end
  end
end
