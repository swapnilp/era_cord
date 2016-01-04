class AdCweekToTimeTableClass < ActiveRecord::Migration
  def change
    add_column :time_table_classes, :cwday, :integer
  end
end
