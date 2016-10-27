class AddTeacherPhoto < ActiveRecord::Migration
  def change
    add_column :g_teachers, :photo, :text
    add_column :teachers, :photo, :text
  end
end
