class AddBookInfoToStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :book_number, :string
    add_column :student_fees, :receipt_number, :string
  end
end
