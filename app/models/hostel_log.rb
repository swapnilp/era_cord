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
    elsif self.reason == "Change room"
      h_room = HostelRoom.select([:id, :name]).where(id: self.param.split(',').first).first.try(:name)
      params = Hash[['old room'].zip([h_room])] if self.param.present?
    elsif self.reason == "Swap room"
      h_student = Student.select([:id, :first_name, :middle_name, :last_name]).where(id: self.param.split(',').first).first.try(:name)
      h_room = HostelRoom.select([:id, :name]).where(id: self.param.split(',').last).first.try(:name)
      params = Hash[['student', 'old room'].zip([h_student, h_room])] if self.param.present?
    elsif self.reason == "Create Hostel"
      params = Hash[['Hostel name', 'Rooms', 'Average fee', 'Student occupancy'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Edit Hostel"
      params = Hash[['Hostel name', 'Rooms', 'Average fee', 'student occupancy'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Edit hostel room"
      params = Hash[['Beds', 'Extra charges', ' Students count'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Add hostel room"
      params = Hash[['Beds', 'Extra charges', ' Students count'].zip(self.param.split(','))] if self.param.present?
    elsif self.reason == "Payment"
      params = Hash[['Amount', 'Date'].zip(self.param.split(','))] if self.param.present?
      params['Date'] = params['Date'].to_date.strftime("%B %Y") if params['Date'].present?
    end
    return params
  end
end
