class CreateExamPoints < ActiveRecord::Migration
  def change
    create_table :exam_points do |t|
      t.references :exam
      t.references :chapters_point
      t.timestamps null: false
    end
  end
end
