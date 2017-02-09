class Vendor < ActiveRecord::Base
  validates_presence_of :name, :nick_name, :mobile, :reason
  belongs_to :organisation
  default_scope { where(organisation_id: Organisation.current_id) }  
end
