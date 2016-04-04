class CreateStudentFees < ActiveRecord::Migration
  def change
    create_table :student_fees do |t|
      t.references :student
      t.references :jkci_class
      t.references :batch
      t.date :date
      t.float :amount
      t.timestamps null: false
    end
  end
end
