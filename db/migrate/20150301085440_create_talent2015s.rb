class CreateTalent2015s < ActiveRecord::Migration
  def change
    create_table :talent2015s do |t|

      t.string :name
      t.string :school_name
      t.string :medium
      t.string :parent_name
      t.string :p_occupation
      t.string :address
      t.string :contact_number
      t.string :email
      t.timestamps null: false
    end
  end
end
