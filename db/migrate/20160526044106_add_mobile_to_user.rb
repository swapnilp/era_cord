class AddMobileToUser < ActiveRecord::Migration
  def change
    remove_column :temporary_organisations, :user_mobile
    add_column :users, :mobile, :string
  end
end
