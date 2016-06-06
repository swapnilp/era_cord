class AddOtherFeeToClassStudents < ActiveRecord::Migration
  def change
    add_column :class_students, :other_fee, :float, default: 0
    add_column :removed_class_students, :other_fee, :float, default: 0
  end
end
