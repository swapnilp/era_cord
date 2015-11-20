class AddIsCompulsoryToSubjects < ActiveRecord::Migration
  def change
    add_column :subjects, :is_compulsory, :boolean, default: true
  end
end
