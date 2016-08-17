class AddCounterCacheToHostel < ActiveRecord::Migration
  def change
    add_column :hostels, :students_count, :integer,  default: 0
    add_column :hostel_rooms, :students_count, :integer,  default: 0
  end
end
