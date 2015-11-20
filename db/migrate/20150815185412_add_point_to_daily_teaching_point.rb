class AddPointToDailyTeachingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :chapters_point_id, :integer
  end
end
