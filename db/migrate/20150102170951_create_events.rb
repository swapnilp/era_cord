class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.string :name
      t.boolean :is_single_day, default: true
      t.date :start_date
      t.date :end_date
      t.string :time
      t.string :description
      t.string :location
      t.string :conductor
      t.timestamps null: false
    end
  end
end
