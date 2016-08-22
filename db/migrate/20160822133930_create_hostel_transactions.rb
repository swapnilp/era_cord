class CreateHostelTransactions < ActiveRecord::Migration
  def change
    create_table :hostel_transactions do |t|
      t.references :hostel
      t.references :hostel_room
      t.references :student
      t.references :organisation
      t.float :amount
      t.date :date
      t.string :is_dues
      t.timestamps null: false
    end
  end
end
