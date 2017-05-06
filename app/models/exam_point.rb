class ExamPoint < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :exam
  belongs_to :chapters_point
  

end
