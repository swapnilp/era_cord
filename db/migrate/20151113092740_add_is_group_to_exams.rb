class AddIsGroupToExams < ActiveRecord::Migration
  def change
    add_column :exams, :is_group, :boolean, default: false
  end
end
