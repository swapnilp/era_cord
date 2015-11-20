class AddClassToDailyTeachingPoints < ActiveRecord::Migration
  def change
    remove_column :daily_teaching_points, :subject_id
    remove_column :daily_teaching_points, :teacher_id
    add_column :daily_teaching_points, :jkci_class_id, :integer
  end
end
