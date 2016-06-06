class MeetingsStudent < ActiveRecord::Base
  belongs_to :student
  belongs_to :organisation
  belongs_to :parents_meeting

  
  default_scope { where(organisation_id: Organisation.current_id) }  
end
