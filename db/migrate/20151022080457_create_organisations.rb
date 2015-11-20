class CreateOrganisations < ActiveRecord::Migration
  def change
    create_table :organisations do |t|
      t.string :name, required: true
      t.string :email, required: true, uniqueness: true
      t.string :mobile, required: true
      
      t.timestamps null: false
    end
  end
end
