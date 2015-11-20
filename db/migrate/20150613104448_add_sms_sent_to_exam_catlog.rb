class AddSmsSentToExamCatlog < ActiveRecord::Migration
  def change
    add_column :exam_catlogs, :absent_sms_sent, :boolean, default: false
  end
end
