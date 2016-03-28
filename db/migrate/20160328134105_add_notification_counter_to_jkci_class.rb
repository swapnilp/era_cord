class AddNotificationCounterToJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :notifications_count, :integer, default: 0
  end
end
