class AddInitialToStudent < ActiveRecord::Migration
  def change
    add_column :students, :initl, :string
  end
end
