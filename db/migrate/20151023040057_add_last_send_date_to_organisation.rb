class AddLastSendDateToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :last_sent, :datetime 
  end
end
