class AddRanksIntoExamcatlog < ActiveRecord::Migration
  def change
    add_column :exam_catlogs, :rank, :integer
  end
end
