class AddDeviceToUser < ActiveRecord::Migration
  def change
    add_column :users, :device_id, :string
    add_column :users, :mpin, :integer
  end
end
