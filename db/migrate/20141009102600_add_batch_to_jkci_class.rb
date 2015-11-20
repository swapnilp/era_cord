class AddBatchToJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :batch_id, :integer, references: :batchs 
  end
end
