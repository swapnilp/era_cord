class ExamPoint < ActiveRecord::Base
  belongs_to :exam
  belongs_to :chapters_point

  default_scope { where(organisation_id: Organisation.current_id) }  
end
