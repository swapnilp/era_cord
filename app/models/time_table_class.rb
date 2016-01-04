class TimeTableClass < ActiveRecord::Base

  belongs_to :time_table
  belongs_to :sub_class
  
  default_scope { where(organisation_id: Organisation.current_id) }  

end
