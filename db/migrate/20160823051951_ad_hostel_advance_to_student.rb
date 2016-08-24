class AdHostelAdvanceToStudent < ActiveRecord::Migration
  def change
    add_column :students, :advances, :float, default: 0
  end
end
