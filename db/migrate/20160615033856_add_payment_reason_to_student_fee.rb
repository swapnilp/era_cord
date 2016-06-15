class AddPaymentReasonToStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :payment_reason_id, :integer, default: 1
    remove_column :student_fees, :reason
  end
end
