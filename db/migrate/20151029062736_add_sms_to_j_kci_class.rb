class AddSmsToJKciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :enable_class_sms, :boolean, default: false
    add_column :jkci_classes, :enable_exam_sms, :boolean, default: false
  end
end
