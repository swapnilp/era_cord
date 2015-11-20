class CreateBatches < ActiveRecord::Migration
  def change
    create_table :batches do |t|
      t.string :name
      t.string :std
      t.string :year
      t.timestamps
    end
  end
end
