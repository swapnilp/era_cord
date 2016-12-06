class CreateHostelLogs < ActiveRecord::Migration
  def change
    create_table :hostel_logs do |t|
      t.references :hostel
      t.references :student
      t.references :hostel_room
      t.references :organisation
      t.string :reason
      t.string :param
      t.timestamps null: false
    end
  end
end
