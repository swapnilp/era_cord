class CreateHolidays < ActiveRecord::Migration
  def change
    create_table :holidays do |t|
      t.date :date
      t.string :reason
      t.boolean :is_goverment
      t.integer :organisation_id, default: 0
      
      t.timestamps null: false
    end
  end
end
