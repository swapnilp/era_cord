class AddIsPresentNilInToClassCatlog < ActiveRecord::Migration
  def change
    change_column :class_catlogs, :is_present, :boolean, :default => nil
  end
end
