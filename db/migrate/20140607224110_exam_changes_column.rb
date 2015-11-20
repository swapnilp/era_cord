class ExamChangesColumn < ActiveRecord::Migration
  def change
    rename_column :exam_results, :users_id, :exam_id
  end
end
