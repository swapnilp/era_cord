class CreateHostels < ActiveRecord::Migration
  def change
    create_table :hostels do |t|
      t.references :organisation
      t.string :name
      t.string :gender
      t.integer :rooms
      t.string :owner
      t.string :address
      t.float :average_fee
      t.integer :student_occupancy
      t.boolean :is_service_tax
      t.float :service_tax
      t.timestamps null: false
    end
  end
end
