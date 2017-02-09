class AddMobileToVendor < ActiveRecord::Migration
  def change
    add_column :vendors, :mobile, :string, null: false
  end
end
