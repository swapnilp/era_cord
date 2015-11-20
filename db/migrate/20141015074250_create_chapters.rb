class CreateChapters < ActiveRecord::Migration
  def change
    create_table :chapters do |t|
      t.string :name
      t.references :subject
      t.integer :chapt_no
      t.integer :std
      t.timestamps
    end
  end
end
