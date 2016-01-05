class ChanceColumnOfTimeTableClasses < ActiveRecord::Migration
  def change
    rename_column :time_table_classes, :type, :slot_type
  end
end
