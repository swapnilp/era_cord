class AddTagToQuestion < ActiveRecord::Migration
  def change
    add_column :questions ,:tag , :string
    add_column :questions ,:page , :string
  end
end
