class AddTitleIntoBatchResult < ActiveRecord::Migration
  def change
    add_column :batch_results, :title, :string
    add_column :batch_results, :is_published, :boolean, default: true
  end
end
