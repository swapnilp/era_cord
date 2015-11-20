class AddSubClassToClassStudents < ActiveRecord::Migration
  def change
    add_column :class_students, :sub_class, :string, default: ',0,'
  end
end
