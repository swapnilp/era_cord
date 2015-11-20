class CreateJkciClasses < ActiveRecord::Migration
  def change
    create_table :jkci_classes do |t|
      t.string :class_name
      t.datetime :class_start_time 
      t.datetime :class_end_time
      t.references :teacher
      t.timestamps
    end
  end
end
