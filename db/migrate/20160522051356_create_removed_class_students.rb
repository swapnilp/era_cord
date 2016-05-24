class CreateRemovedClassStudents < ActiveRecord::Migration
  def change
    create_table :removed_class_students do |t|
      t.references :jkci_class
      t.references :student
      t.integer :organisation_id
      t.float :collected_fee
      t.integer :batch_id
      t.timestamps null: false
    end
  end
end
