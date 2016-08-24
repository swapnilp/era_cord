class AddFeeMonthsForHostel < ActiveRecord::Migration
  def change
    add_column :hostels, :months, :integer, default: 1
    add_column :hostels, :start_date, :date
  end
end
