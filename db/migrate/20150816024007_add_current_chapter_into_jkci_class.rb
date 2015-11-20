class AddCurrentChapterIntoJkciClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :current_chapter_id, :integer
  end
end
