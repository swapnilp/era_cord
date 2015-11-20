class AddLastPresentInToStudent < ActiveRecord::Migration
  def change
    add_column :students, :last_present, :datetime
  end
end
