class CreateQuestions < ActiveRecord::Migration
  def change
    create_table :questions do |t|
      t.string :email
      t.string :question
      t.string :is_admin, default: true
      t.timestamps null: false
    end
  end
end
