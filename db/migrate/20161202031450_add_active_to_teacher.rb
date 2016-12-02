class AddActiveToTeacher < ActiveRecord::Migration
  def change
    add_column :teachers, :active, :boolean, default: true
  end
end
