class CreateDailyTeachingPoints < ActiveRecord::Migration
  def change
    create_table :daily_teaching_points do |t|
      t.references :subject
      t.datetime :date
      t.text :points
      t.references :teacher
      t.timestamps
    end
  end
end
