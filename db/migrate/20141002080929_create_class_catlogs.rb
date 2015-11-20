class CreateClassCatlogs < ActiveRecord::Migration
  def change
    create_table :class_catlogs do |t|
      t.references :student
      t.references :jkci_class
      t.references :daily_teaching_point
      t.date :date
      t.timestamps
    end
  end
end
