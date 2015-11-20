class AddActionToNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :actions, :string
  end
end
