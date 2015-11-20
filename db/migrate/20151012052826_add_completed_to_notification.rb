class AddCompletedToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :is_completed, :boolean, default: false
  end
end
