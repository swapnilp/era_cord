class CreateExamCatlogs < ActiveRecord::Migration
  def change
    create_table :exam_catlogs do |t|
      t.references :exam
      t.references :student
      t.references :jkci_class
      t.float :marks
      t.boolean :is_present
      t.boolean :is_recover, default: false
      t.date :recover_date
      t.text :remark
      t.timestamps
    end
  end
end
