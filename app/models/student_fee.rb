class StudentFee < ActiveRecord::Base
  belongs_to :student
  belongs_to :batch
  belongs_to :jkci_class
  belongs_to :organisation
  
  default_scope { where(organisation_id: Organisation.current_id) }    
end
