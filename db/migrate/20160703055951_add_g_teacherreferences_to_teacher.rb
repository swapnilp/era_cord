class AddGTeacherreferencesToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :g_teacher_id, :integer
  end
end
