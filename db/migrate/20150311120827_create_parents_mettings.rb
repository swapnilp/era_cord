class CreateParentsMettings < ActiveRecord::Migration
  def change
    create_table :parents_meetings do |t|
      t.string :agenda
      t.datetime :date
      t.string :contact_person
      t.references :batch
      t.boolean :sms_sent, default: false
      t.timestamps null: false
    end
  end
end
