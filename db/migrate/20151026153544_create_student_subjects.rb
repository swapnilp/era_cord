class CreateStudentSubjects < ActiveRecord::Migration
  def change
    create_table :student_subjects do |t|
      t.references :student
      t.references :subject
      t.integer :batch_id
      t.timestamps null: false
    end
  end
end
