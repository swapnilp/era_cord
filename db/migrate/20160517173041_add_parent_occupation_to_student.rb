class AddParentOccupationToStudent < ActiveRecord::Migration
  def change
    add_column :students, :parent_occupation, :string
  end
end
