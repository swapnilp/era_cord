class ReindexUsersByEmailAndSubdomain < ActiveRecord::Migration
  def up
    remove_index :users, :email
    add_index :users, [:email]#, :unique => false
  end
  def down
    remove_index :users, [:email]
    add_index :users, :email, :unique => true
  end
end
