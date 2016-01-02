class CreateTimeTableClasses < ActiveRecord::Migration
  def change
    create_table :time_table_classes do |t|
      t.references :organisation
      t.references :sub_class
      t.references :time_table
      t.boolean :is_break
      t.string :type
      t.string :start_time
      t.string :end_time
      t.integer :durations
      t.timestamps null: false
    end
  end
end
