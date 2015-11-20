class AddTeacherToDailyTeachingPoints < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :teacher_id, :integer
  end
end
