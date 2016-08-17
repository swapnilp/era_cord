class AddHostelToStudent < ActiveRecord::Migration
  def change
    add_column :students, :hostel_id, :integer
    add_column :students, :hostel_room_id, :integer
  end
end
