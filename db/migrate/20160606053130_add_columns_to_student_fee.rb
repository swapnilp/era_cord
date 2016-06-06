class AddColumnsToStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :is_fee, :boolean, default: true
    add_column :student_fees, :reason, :string, default: "Fee"
  end
end
