class AddAbsentCountToExams < ActiveRecord::Migration
  def change
    add_column :exams, :students_count, :integer
    add_column :exams, :absents_count, :integer
  end
end
