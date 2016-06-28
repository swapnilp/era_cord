class AddUniqColumnTo < ActiveRecord::Migration
  def change
    add_index :teachers, :email, :unique => true
    remove_column :teachers, :subject_id
  end
end
