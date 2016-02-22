class SendMessageToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :is_send_message, :boolean, default: false
  end
end
