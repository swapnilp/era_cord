class Hostel < ActiveRecord::Base
  belongs_to :organisation
  has_many :hostel_rooms
  has_many :students
  has_many :hostel_transactions
  has_many :hostel_logs
  
  default_scope { where(organisation_id: Organisation.current_id) }    


  def possible_other_room(room_id)
    hostel_rooms.where("id != ? && beds > students_count", room_id)
  end

  def calculate_fee
    calc_months = ((Date.today.to_time - self.start_date.to_time)/1.month.second).to_i if self.start_date.present? && self.months.present?
    if calc_months.present?
      fees_months = calc_months % self.months
      fees_months = self.months if fees_months.zero?
      collect_fee(fees_months)
    else
      collect_fee(1)
    end
  end

  def fee_months_arry
    (self.start_month...(self.start_month+12)).to_a.map{|a| (a % 12) == 0 ? 12 : (a % 12)}
  end

  def add_log_create
    self.hostel_logs.build({organisation_id: self.organisation_id, reason: "Create Hostel", param: "#{name}, #{rooms}, #{average_fee}, #{student_occupancy}"}).save
  end

  def add_log_edit
    self.hostel_logs.build({organisation_id: self.organisation_id, reason: "Edit Hostel", param: "#{name}, #{rooms}, #{average_fee}, #{student_occupancy}"}).save
  end

  def collect_fee(fee_months)
    students.each do |student|
      fee_date = Date.today.beginning_of_month
      (1..fee_months).to_a.each do |index|
        hostel_transaction = hostel_transactions.find_or_initialize_by({date: fee_date, student_id: student.id})
        hostel_transaction.hostel_room_id =  student.hostel_room_id
        hostel_transaction.organisation_id =  student.organisation_id
        hostel_transaction.hostel_id = student.hostel_id
        room_fee = self.average_fee + hostel_transaction.hostel_room.extra_charges
        hostel_transaction.amount = room_fee
        if student.advances <= room_fee
          hostel_transaction.is_dues = true
        end
        if hostel_transaction.new_record? && hostel_transaction.save
          student.remove_amount_from_advances(room_fee)
        end
        fee_date = fee_date.next_month.beginning_of_month
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
                    occupied_students: students_count,
                    months: months,
                    start_month: start_month
                  })
  end
end
