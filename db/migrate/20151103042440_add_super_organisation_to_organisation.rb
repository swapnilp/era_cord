class AddSuperOrganisationToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :super_organisation_id, :integer
    Organisation.all.each do |org| 
      org.update_attributes({super_organisation_id: org.id})
    end
  end
end
