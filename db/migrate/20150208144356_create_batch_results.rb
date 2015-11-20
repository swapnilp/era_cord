class CreateBatchResults < ActiveRecord::Migration
  def change
    create_table :batch_results do |t|
      t.string :batch
      t.string :description
      t.string :cover_img
      t.timestamps null: false
    end
  end
end
