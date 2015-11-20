class AddIsIgnoreIntoExamCatlog < ActiveRecord::Migration
  def change
    add_column :exam_catlogs, :is_ingored, :boolean, :default => nil
  end
end
