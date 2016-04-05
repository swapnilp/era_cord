class AddDataIntoStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :payment_type, :string, default: "cash"
    add_column :student_fees, :bank_name, :string
    add_column :student_fees, :cheque_number, :string
    add_column :student_fees, :cheque_issue_date, :string
    add_column :student_fees, :organisation_id, :integer
  end
end
