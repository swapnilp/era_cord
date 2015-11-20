class AddPresentyToClassCatlog < ActiveRecord::Migration
  def change
    add_column :class_catlogs, :is_present, :boolean, default: false
    add_column :class_catlogs, :is_recover, :boolean, default: false
    add_column :class_catlogs, :recover_date, :date
  end
end
