class CreateAttendances < ActiveRecord::Migration
  def change
    create_table :attendances do |t|
      t.references :student, null: false
      t.integer :organisation_id, null: false
      t.date :date
      t.time :in_time
      t.time :out_time
      t.timestamps null: false
    end
  end
end
