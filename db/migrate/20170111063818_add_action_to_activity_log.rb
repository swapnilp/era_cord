class AddActionToActivityLog < ActiveRecord::Migration
  def change
    add_column :activity_logs, :action, :string
    rename_column :activity_logs, :object_id, :obj_id
    rename_column :activity_logs, :attributes, :attr
    rename_column :activity_logs, :organisation_id_id, :organisation_id
  end
end
