class RemoveEmailIniqOrganisaiton < ActiveRecord::Migration
  def change
    remove_index :organisations, :email
    add_index :organisations, :email
  end
end
