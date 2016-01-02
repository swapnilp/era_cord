class StudentSubject < ActiveRecord::Base
  belongs_to :subject
  belongs_to :student
  
  default_scope { where(organisation_id: Organisation.current_id) }  
end
