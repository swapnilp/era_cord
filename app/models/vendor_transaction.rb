class VendorTransaction < ActiveRecord::Base

  belongs_to :vendor
  belongs_to :organisation
  
  default_scope { where(organisation_id: Organisation.current_id) }  
end
