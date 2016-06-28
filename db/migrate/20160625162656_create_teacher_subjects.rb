class CreateTeacherSubjects < ActiveRecord::Migration
  def change
    create_table :teacher_subjects do |t|
      t.references :teacher
      t.references :subject
      t.timestamps null: false
    end
  end
end
