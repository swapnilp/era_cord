class CreateExamAbsents < ActiveRecord::Migration
  def change
    create_table :exam_absents do |t|
      t.references :student
      t.references :exam
      t.boolean :sms_sent
      t.boolean :email_sent
      t.boolean :reattend
      t.datetime :attend_date
      t.timestamps
    end
  end
end
