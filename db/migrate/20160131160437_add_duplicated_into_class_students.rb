class AddDuplicatedIntoClassStudents < ActiveRecord::Migration
  def change
    add_column :class_students, :is_duplicate, :boolean, default: false
    add_column :class_students, :duplicate_field, :string, default: nil
    add_column :class_students, :is_duplicate_accepted, :boolean,  default: false
  end
end
