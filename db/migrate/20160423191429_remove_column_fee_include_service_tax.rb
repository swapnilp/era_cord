class RemoveColumnFeeIncludeServiceTax < ActiveRecord::Migration
  def change
    remove_column :organisations, :fee_include_service_tax
  end
end
