class HostelLog < ActiveRecord::Base
  belongs_to :hostel_room
  belongs_to :hostel
  belongs_to :organisation
  belongs_to :student

  def hostel_json(options = {})
    options.merge({
                    id: id,
                    date: created_at.to_date,
                    student_name:  student.try(:name),
                    hostel: hostel.try(:name),
                    room: hostel_room.try(:name),
                    reason: reason,
                    param: disp_params,
                    is_param: param.present?
                  })
  end

  def disp_params
    params = {}
    if self.reason == "Allocate hostel"
      params = nil
    elsif self.reason == "Deallocate hostel"
      params = nil
    elsif self.reason == "Allocate room"
      params = nil
    elsif self.reason == "Create Hostel"
      params = Hash[['Hostel name', 'Rooms', 'Average fee', 'Student occupancy'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Edit Hostel"
      params = Hash[['Hostel name', 'Rooms', 'Average fee', 'student occupancy'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Edit hostel room"
      params = Hash[['Beds', 'Extra charges', ' Students count'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Add hostel room"
      params = Hash[['Beds', 'Extra charges', ' Students count'].zip(self.param.split(','))] if self.param.present?
    end
    return params
  end
end
