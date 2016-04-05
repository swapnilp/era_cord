class AddAccountSmsToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :account_sms, :text
  end
end
