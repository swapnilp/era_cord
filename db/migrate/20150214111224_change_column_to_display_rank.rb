class ChangeColumnToDisplayRank < ActiveRecord::Migration
  def change
    change_column :results, :disp_rank,  :string
  end
end
