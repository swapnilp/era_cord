class AddTeacherToTimeTableClass < ActiveRecord::Migration
  def change
    add_column :time_table_classes, :teacher_id, :integer
  end
end
