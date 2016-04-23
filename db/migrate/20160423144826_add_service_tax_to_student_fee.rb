class AddServiceTaxToStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :service_tax, :float, default: 0
  end
end
