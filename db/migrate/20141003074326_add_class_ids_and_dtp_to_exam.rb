class AddClassIdsAndDtpToExam < ActiveRecord::Migration
  def change
    add_column :exams, :class_ids, :string
    add_column :exams, :daily_teaching_points, :string
  end
end
