class AddStudentIdIntoSendSms < ActiveRecord::Migration
  def change
    add_column :sms_sents, :student_id, :integer
  end
end
