class AddSubjectIdToTimeTableClass < ActiveRecord::Migration
  def change
    add_column :time_table_classes, :subject_id, :integer
  end
end
