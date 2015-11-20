class AddParentIdToExam < ActiveRecord::Migration
  def change
    add_column :exams, :parent_id, :integer
    add_column :exams, :ancestry, :string
    
  end
end
