class AddAbsentNotificationDaysToOrganisaiton < ActiveRecord::Migration
  def change
    add_column :organisations, :absent_days, :integer, default: 20
  end
end
