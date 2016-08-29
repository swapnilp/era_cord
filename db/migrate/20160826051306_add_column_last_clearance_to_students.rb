class AddColumnLastClearanceToStudents < ActiveRecord::Migration
  def change
    add_column :students, :clearance, :date
  end
end
