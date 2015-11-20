class AddEmailCodeToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :email_code, :string
    add_column :organisations, :mobile_code, :string
  end
end
