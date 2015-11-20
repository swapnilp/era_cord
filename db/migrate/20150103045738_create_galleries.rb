class CreateGalleries < ActiveRecord::Migration
  def change
    create_table :galleries do |t|
      t.string :image_file_name
      t.string :image_content_type
      t.string :image_file_size
      t.float :height
      t.float :width
      t.has_attached_file :image
      t.string :location
      t.string :description 
      t.date :event_date
      t.integer :album_id, default: nil
      t.timestamps null: false
    end
  end
end
