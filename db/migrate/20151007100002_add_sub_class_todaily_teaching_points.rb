class AddSubClassTodailyTeachingPoints < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :sub_classes, :string
  end
end
