class AddIsEnableToUser < ActiveRecord::Migration
  def change

    add_column :users, :is_enable, :boolean, default: true
  end
end
