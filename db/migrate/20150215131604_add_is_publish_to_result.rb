class AddIsPublishToResult < ActiveRecord::Migration
  def change
    add_column :results, :is_published, :boolean, default: true
  end
end
