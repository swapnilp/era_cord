class CreateExams < ActiveRecord::Migration
  def change
    create_table :exams do |t|
      t.references :subject
      t.string :conducted_by
      t.integer :marks
      t.datetime :exam_date
      t.float :duration
      t.string :exam_type
      t.integer :std
      t.string :remark
      t.boolean :is_result_decleared
      t.boolean :is_completed
      t.timestamps
    end
  end
end
