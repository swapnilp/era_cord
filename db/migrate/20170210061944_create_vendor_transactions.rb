class CreateVendorTransactions < ActiveRecord::Migration
  def change
    create_table :vendor_transactions do |t|
      t.references :vendor
      t.references :organisation
      t.string :type
      t.float :amount
      t.string :cheque_number
      t.date :issue_date
      t.string :transaction_type, null: false, default: "Debit"
      t.string :user_email      
      t.timestamps null: false
    end
  end
end
