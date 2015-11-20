class AddRollNumberToClassStudents < ActiveRecord::Migration
  def change
    add_column :class_students, :roll_number, :integer
  end
end
