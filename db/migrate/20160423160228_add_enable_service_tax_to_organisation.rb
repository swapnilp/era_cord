class AddEnableServiceTaxToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :enable_service_tax, :boolean, default: false
  end
end
