class HostelTransaction < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :hostel
  belongs_to :student
  has_many :hostel_transactions
  
  default_scope { where(organisation_id: Organisation.current_id) }
  
end
