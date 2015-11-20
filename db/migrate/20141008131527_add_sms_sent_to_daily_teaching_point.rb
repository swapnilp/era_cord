class AddSmsSentToDailyTeachingPoint < ActiveRecord::Migration
  def change
    add_column :daily_teaching_points, :is_sms_sent, :boolean, default: false
  end
end
