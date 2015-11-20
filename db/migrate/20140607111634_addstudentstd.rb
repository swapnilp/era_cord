class Addstudentstd < ActiveRecord::Migration 
  def change
    add_column :students, :std, :integer
  end
end
