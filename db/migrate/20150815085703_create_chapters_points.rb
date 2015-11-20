class CreateChaptersPoints < ActiveRecord::Migration
  def change
    create_table :chapters_points do |t|
      t.references :chapter
      t.string :name
      t.string :weight
      t.timestamps null: false
    end
  end
end
