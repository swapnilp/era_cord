class AddNotificationIdToUser < ActiveRecord::Migration
  def change
    add_column :users, :notification_id, :integer
    add_column :users, :os, :string
  end
end
