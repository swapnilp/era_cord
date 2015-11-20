class ChaptersPoint < ActiveRecord::Base
  belongs_to :chapter
  has_many :daily_teaching_point
end
