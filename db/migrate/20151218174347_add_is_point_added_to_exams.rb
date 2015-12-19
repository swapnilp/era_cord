class AddIsPointAddedToExams < ActiveRecord::Migration
  def change
    add_column :exams, :is_point_added, :boolean, default: false
  end
end
