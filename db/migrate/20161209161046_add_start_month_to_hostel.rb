class AddStartMonthToHostel < ActiveRecord::Migration
  def change
    add_column :hostels, :start_month, :integer, null: false, default: 6
  end
end
