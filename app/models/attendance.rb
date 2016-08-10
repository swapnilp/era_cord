class Attendance < ActiveRecord::Base
  default_scope { where(organisation_id: Organisation.current_id) }  

  belongs_to :student
  scope :todays_attendances, -> { where(date: Date.today) }
  
  
  
end
