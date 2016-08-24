class ChangeColumnIsDueInHostelTransaction < ActiveRecord::Migration
  def up
    change_column :hostel_transactions, :is_dues, :boolean, default: false
  end

  def down
    change_column :hostel_transactions, :is_dues, :string
  end
end
