class AddStandardIdToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :standard_id, :integer
  end
end
