class AddUserToStudentFee < ActiveRecord::Migration
  def change
    add_column :student_fees, :user_id, :integer
  end
end
