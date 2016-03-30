class AddClassRoomToTimeTableClass < ActiveRecord::Migration
  def change
    add_column :time_table_classes, :class_room, :string
  end
end
