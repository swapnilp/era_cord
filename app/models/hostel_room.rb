class HostelRoom < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :hostel
  has_many :students
  has_many :hostel_transactions
  has_many :hostel_logs
  
  def remaining_beds
    return beds - students_count
  end

  def add_log_new_room
    self.hostel_logs.build({organisation_id: self.organisation_id, hostel_id: self.hostel_id, reason: "Add hostel room", param: "#{self.beds}, #{self.extra_charges}, #{self.students_count}"}).save
  end

  def add_log_edit_room
    self.hostel_logs.build({organisation_id: self.organisation_id, hostel_id: self.hostel_id, reason: "Edit hostel room", param: "#{self.beds}, #{self.extra_charges}, #{self.students_count}"}).save
  end

  def add_log_delete_room
    self.hostel_logs.build({organisation_id: self.organisation_id, hostel_id: self.hostel_id, reason: "Delete hostel room", param: "#{self.beds}, #{self.extra_charges}, #{self.students_count}"}).save
  end

  def delete_room
    self.students.each do |student|
      student.hostel_log_deallocate
      student.update_attributes({hostel_room_id: nil})
    end
    self.add_log_delete_room
    self.destroy
  end

  def as_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: self.organisation_id,
                    name: name,
                    beds: beds,
                    extra_charges: extra_charges,
                    students_count: students_count,
                    students: students.map(&:hostel_json),
                    is_available: (beds - students_count) > 0
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
