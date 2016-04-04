class ChangeStringIntoFlaotTimeTableClassTimeColumn < ActiveRecord::Migration
  def change
    change_column :time_table_classes, :start_time, :float
    change_column :time_table_classes, :end_time, :float
  end
end
