class AddEnableSmsToStudent < ActiveRecord::Migration
  def change
    add_column :students, :enable_sms, :boolean, default: false
  end
end
