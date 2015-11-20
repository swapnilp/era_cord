class Result < ActiveRecord::Migration
  def change
    create_table :results do |t|
      t.string :name
      t.string :marks
      t.string :stream
      t.string :college
      t.integer :rank
      t.integer :disp_rank
      t.references :results_photo
      t.references :batch
      t.references :student
      t.timestamps null: false
    end
  end
end
