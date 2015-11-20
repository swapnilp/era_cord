class AddJkciClassIdToNotificaiton < ActiveRecord::Migration
  def change
    add_column :notifications, :jkci_class_id, :integer
  end
end
