class CreateClassStudents < ActiveRecord::Migration
  def change
    create_table :class_students do |t|
      t.references :jkci_class
      t.references :student
      t.timestamps
    end
  end
end
