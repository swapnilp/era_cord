class AddSmsSentToClassCatlog < ActiveRecord::Migration
  def change
    add_column :class_catlogs, :sms_sent, :boolean, default: false
  end
end
