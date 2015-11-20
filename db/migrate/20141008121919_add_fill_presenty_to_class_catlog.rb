class AddFillPresentyToClassCatlog < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :is_fill_catlog, :boolean, default: false
  end
end
