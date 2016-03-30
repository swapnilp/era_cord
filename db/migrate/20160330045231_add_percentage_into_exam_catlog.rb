class AddPercentageIntoExamCatlog < ActiveRecord::Migration
  def change
    add_column :exam_catlogs, :percentage, :float, default: 0
  end
end
