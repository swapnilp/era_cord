class Hostel < ActiveRecord::Base
  belongs_to :organisation
  has_many :hostel_rooms
  has_many :students
  has_many :hostel_transactions
  
  default_scope { where(organisation_id: Organisation.current_id) }    


  def possible_other_room(room_id)
    hostel_rooms.where("id != ? && beds > students_count", room_id)
  end

  def collect_fee
    students.each do |student|
      hostel_transaction = hostel_transactions.find_or_initialize_by({date: Date.today.beginning_of_month, student_id: student.id})
      hostel_transaction.hostel_room_id =  student.hostel_room_id
      hostel_transaction.hostel_id = student.hostel_id
      room_fee = self.average_fee + hostel_transaction.hostel_room.extra_charges
      hostel_transaction.amount = room_fee
      if student.advances <= room_fee
        hostel_transaction.is_dues = true
      end
      if hostel_transaction.new_record? && hostel_transaction.save
        student.remove_amount_from_advances(room_fee)
      end
    end
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
