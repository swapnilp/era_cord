class AddPriorityToStandard < ActiveRecord::Migration
  def change
    add_column :standards, :priority, :integer
  end
end
