class AddIsDisabledToStudent < ActiveRecord::Migration
  def change
    add_column :students, :is_disabled, :boolean, default: false
  end
end
