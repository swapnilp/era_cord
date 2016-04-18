class AddFeeToClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :fee, :float, default: nil
    
    JkciClass.unscoped.each do |jkci_class|
      org_std = OrganisationStandard.unscoped.where(standard_id: jkci_class.standard_id , organisation_id: jkci_class.organisation_id).first
      jkci_class.update_attributes({fee: org_std.total_fee})
    end
  end
end
