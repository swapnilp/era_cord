class AddActiveToBatch < ActiveRecord::Migration
  def change
    add_column :batches, :is_active, :boolean, default: true
    add_column :jkci_classes, :is_active, :boolean, default: true
  end
end
