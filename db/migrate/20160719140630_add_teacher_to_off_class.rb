class AddTeacherToOffClass < ActiveRecord::Migration
  def change
    add_column :off_classes, :teacher_id, :integer
  end
end
