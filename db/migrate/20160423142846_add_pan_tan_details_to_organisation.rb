class AddPanTanDetailsToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :pan_number, :string
    add_column :organisations, :tan_number, :string
    add_column :organisations, :service_tax, :float, default: 14
    add_column :organisations, :fee_include_service_tax, :boolean, default: false
  end
end
