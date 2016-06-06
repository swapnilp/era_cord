class CreateMeetingsStudents < ActiveRecord::Migration
  def change
    create_table :meetings_students do |t|
      t.references :parents_meeting
      t.references :student
      t.boolean :sent_sms, default: false
      t.string :mobile
      t.references :organisation
      t.timestamps null: false
    end
  end
end
