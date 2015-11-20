class CreateStudents < ActiveRecord::Migration
  def change
    create_table :students do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :mobile
      t.string :parent_name
      t.string :p_mobile
      t.string :p_email
      t.text :address
      t.string :group
      t.string :rank
      t.timestamps
    end
  end
end
