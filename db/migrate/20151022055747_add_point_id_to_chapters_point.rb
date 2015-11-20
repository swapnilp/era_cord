class AddPointIdToChaptersPoint < ActiveRecord::Migration
  def change
    add_column :chapters_points, :point_id, :string
  end
end
