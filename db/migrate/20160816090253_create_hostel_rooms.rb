class CreateHostelRooms < ActiveRecord::Migration
  def change
    create_table :hostel_rooms do |t|
      t.references :hostel
      t.references :organisation
      t.string :name
      t.integer :beds
      t.integer :extra_charges
      t.timestamps null: false
    end
  end
end
