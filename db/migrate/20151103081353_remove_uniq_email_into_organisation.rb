class RemoveUniqEmailIntoOrganisation < ActiveRecord::Migration
  def change
    change_column :organisations, :email, :string, :null => false
  end
end
