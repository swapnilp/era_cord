class Vendor < ActiveRecord::Base
  
  belongs_to :organisation
  default_scope { where(organisation_id: Organisation.current_id) }  
end
