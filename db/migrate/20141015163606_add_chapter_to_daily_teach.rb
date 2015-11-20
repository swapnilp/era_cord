class AddChapterToDailyTeach < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :chapter_id, :integer
  end
end
