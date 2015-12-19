class ExamPoint < ActiveRecord::Base
  belongs_to :exam
  belongs_to :chapters_point
end
