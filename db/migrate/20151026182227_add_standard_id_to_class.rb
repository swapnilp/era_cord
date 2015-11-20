class AddStandardIdToClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :standard_id, :integer
  end
end
