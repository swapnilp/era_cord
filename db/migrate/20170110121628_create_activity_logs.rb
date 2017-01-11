class CreateActivityLogs < ActiveRecord::Migration
  def change
    create_table :activity_logs do |t|
      t.string :type
      t.references :organisation_id
      t.integer :object_id
      t.references :user_email
      t.string :reason
      t.string :attributes
      t.timestamps null: false
    end
  end
end
