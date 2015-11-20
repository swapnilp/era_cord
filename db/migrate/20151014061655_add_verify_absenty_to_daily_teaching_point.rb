class AddVerifyAbsentyToDailyTeachingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :verify_absenty, :boolean, default: false
  end
end
