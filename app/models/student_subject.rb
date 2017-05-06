class StudentSubject < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :subject
  belongs_to :student
  

end
