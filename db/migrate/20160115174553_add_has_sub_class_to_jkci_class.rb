class AddHasSubClassToJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :has_sub_class, :boolean, default: false
  end
end
