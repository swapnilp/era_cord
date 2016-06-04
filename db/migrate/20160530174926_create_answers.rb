class CreateAnswers < ActiveRecord::Migration
  def change
    create_table :answers do |t|
      t.references :question
      t.string :answer
      t.references :answer
      t.timestamps null: false
    end
  end
end
