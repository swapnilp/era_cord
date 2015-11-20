class AddIsPublicEvent < ActiveRecord::Migration
  def change
    add_column :events, :is_public_event, :boolean, default: false
  end
end
