class AddSubClassToExams < ActiveRecord::Migration
  def change
    add_column :exams, :sub_classes, :string
  end
end
