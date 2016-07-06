class AddObjTypeToResetPassword < ActiveRecord::Migration
  def change
    add_column :reset_passwords, :object_type, :string, default: "User"
  end
end
