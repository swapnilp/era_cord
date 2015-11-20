class AddClassToExam < ActiveRecord::Migration
  def change
    add_column :exams, :jkci_class_id, :integer
  end
end
