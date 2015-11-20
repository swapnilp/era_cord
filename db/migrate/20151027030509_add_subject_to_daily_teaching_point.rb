class AddSubjectToDailyTeachingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :subject_id, :integer
  end
end
