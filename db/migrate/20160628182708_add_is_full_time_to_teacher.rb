class AddIsFullTimeToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :is_full_time, :boolean, default: true
  end
end
