class AddMonthInHostelTransactions < ActiveRecord::Migration
  def change
    add_column :hostel_transactions, :pay_month, :integer
  end
end
