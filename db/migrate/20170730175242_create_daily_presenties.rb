class CreateDailyPresenties < ActiveRecord::Migration
  def change
    create_table :daily_presenties do |t|
      t.integer :organisation_id
      t.references :student
      t.datetime :time
      t.string :swap_type, default: "IN"
      t.timestamps null: false
    end
  end
end
