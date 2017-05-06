class Attendance < ActiveRecord::Base
  acts_as_organisation

  belongs_to :student
  scope :todays_attendances, -> { where(date: Date.today) }
end
