class AddFollowapToClassCatlog < ActiveRecord::Migration
  def change
    add_column :class_catlogs, :is_followed, :boolean, default: false
    add_column :exam_catlogs, :is_followed, :boolean, default: false
  end
end
