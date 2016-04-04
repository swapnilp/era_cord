class AddTotalFeeToOrganisationStandard < ActiveRecord::Migration
  def change
    add_column :organisation_standards, :total_fee, :float, default: 0
  end
end
