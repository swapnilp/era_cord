class AddIsMailAndIsFemail < ActiveRecord::Migration
  def change
    add_column :hostels, :allow_males, :boolean, default: true
    add_column :hostels, :allow_females, :boolean, default: false
  end
end
