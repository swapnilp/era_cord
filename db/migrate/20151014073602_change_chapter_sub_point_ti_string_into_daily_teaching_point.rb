class ChangeChapterSubPointTiStringIntoDailyTeachingPoint < ActiveRecord::Migration
  def change
    change_column :daily_teaching_points, :chapters_point_id,  :string
  end
end
