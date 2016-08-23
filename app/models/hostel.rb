class Hostel < ActiveRecord::Base
  belongs_to :organisation
  has_many :hostel_rooms
  has_many :students
  has_many :hostel_transactions
  
  default_scope { where(organisation_id: Organisation.current_id) }    


  def possible_other_room(room_id)
    hostel_rooms.where("id != ? && beds > students_count", room_id)
  end
  
  def as_json(options = {})
    options.merge({
                    id: id,
                    organisation_id: self.organisation_id,
                    name: name, 
                    gender: gender, 
                    rooms: rooms, 
                    owner: owner, 
                    address: address, 
                    average_fee: average_fee,
                    student_occupancy: student_occupancy,
                    is_service_tax: is_service_tax,
                    service_tax: service_tax,
                    occupied_students: students_count
                  })
  end
end
