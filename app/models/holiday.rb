class Holiday < ActiveRecord::Base
  belongs_to :organisation
  
  default_scope { where("organisation_id in (?)", [0, Organisation.current_id].flatten.compact) }  
end
