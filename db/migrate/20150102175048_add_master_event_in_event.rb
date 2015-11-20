class AddMasterEventInEvent < ActiveRecord::Migration
  def change
    add_column :events, :master_event_id, :integer, default: nil
  end
end
