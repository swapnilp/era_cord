class AddCurrentActiveToJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :is_current_active, :boolean, default: false
  end
end
