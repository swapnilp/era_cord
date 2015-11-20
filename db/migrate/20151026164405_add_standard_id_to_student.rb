class AddStandardIdToStudent < ActiveRecord::Migration
  def change
    add_column :students, :standard_id, :integer
    add_column :standards, :is_active, :boolean, default: true
  end
end
