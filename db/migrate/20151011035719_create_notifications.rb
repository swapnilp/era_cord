class CreateNotifications < ActiveRecord::Migration
  def change
    create_table :notifications do |t|
      t.string :message
      t.string :object_type
      t.integer :object_id
      t.string :url
      t.string :comment
      t.timestamps null: false
    end
  end
end
