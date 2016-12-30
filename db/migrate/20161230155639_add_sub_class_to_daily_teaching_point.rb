class AddSubClassToDailyTeachingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :sub_class_id, :integer
  end
end
