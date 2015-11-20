class CreateExamResults < ActiveRecord::Migration
  def change
    create_table :exam_results do |t|
      t.references :student
      t.references :users
      t.float :marks
      t.boolean :sms_sent
      t.boolean :email_sent
      t.boolean :late_attend
      t.timestamps
    end
  end
end
