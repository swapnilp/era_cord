class AddCounterIntoDailyTeacingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :class_catlogs_count, :integer, default: 0
  end
end
