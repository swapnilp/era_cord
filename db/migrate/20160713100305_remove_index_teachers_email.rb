class RemoveIndexTeachersEmail < ActiveRecord::Migration
  def change
    remove_index :teachers, :email
    add_index :teachers, :email
  end
end
