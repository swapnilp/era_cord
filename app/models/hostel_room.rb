class HostelRoom < ActiveRecord::Base
  belongs_to :organisation
  belongs_to :hostel
  has_many :students
  has_many :hostel_transactions
  
  default_scope { where(organisation_id: Organisation.current_id) }

  def remaining_beds
    return beds - students_count
  end
  

  def as_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: self.organisation_id,
                    name: name,
                    beds: beds,
                    extra_charges: extra_charges,
                    students_count: students_count,
                    students: students.map(&:hostel_json)
                  })
  end

  def change_room_json(options = {})
    options.merge({
                    id: id,
                    name: name,
                    extra_charges: extra_charges
                  })
  end
end
