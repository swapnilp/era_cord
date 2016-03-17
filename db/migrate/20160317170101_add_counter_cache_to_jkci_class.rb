class AddCounterCacheToJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :class_students_count, :integer, default: 0
  end
end
