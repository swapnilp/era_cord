class Hostel < ActiveRecord::Base
  acts_as_organisation

  has_many :hostel_rooms
  has_many :students
  has_many :hostel_transactions
  has_many :hostel_logs
  


  def possible_other_room(room_id)
    hostel_rooms.where("id != ? && beds > students_count", room_id)
  end

  def calculate_fee
    collect_fee
  end

  def fee_months_arry
    dates = []
    get_months = (self.start_month...(self.start_month+12)).to_a.map{|a| (a % 12) == 0 ? 12 : (a % 12)}.in_groups_of(self.months || 1).select {|months_arry| months_arry.include?(Date.today.month)}.flatten.compact
    index = get_months.index(Date.today.month)
    get_months = get_months.slice(index, 12)

    todate  = Date.today.beginning_of_month 
    get_months.each do |mon|
      dates << todate
      todate = todate.next_month
    end
    return dates 
  end

  def add_log_create
    self.hostel_logs.build({organisation_id: self.organisation_id, reason: "Create Hostel", param: "#{name}, #{rooms}, #{average_fee}, #{student_occupancy}"}).save
  end

  def add_log_edit
    self.hostel_logs.build({organisation_id: self.organisation_id, reason: "Edit Hostel", param: "#{name}, #{rooms}, #{average_fee}, #{student_occupancy}"}).save
  end
  
  def add_log_payment(room_id, student_id, amount, date)
    self.hostel_logs.build({organisation_id: self.organisation_id, student_id: student_id, hostel_room_id: room_id,  reason: "Payment", param: "#{amount}, #{date}"}).save
  end

  def collect_fee
    students.each do |student|
      transaction do
        fee_dates = self.fee_months_arry
        fee_dates.each do |fee_date|
          hostel_transaction = hostel_transactions.find_or_initialize_by({date: fee_date, student_id: student.id})
          hostel_transaction.hostel_room_id = student.hostel_room_id
          hostel_transaction.organisation_id = student.organisation_id
          hostel_transaction.hostel_id = student.hostel_id
          room_fee = self.average_fee + hostel_transaction.hostel_room.extra_charges
          hostel_transaction.amount = room_fee
          if student.advances <= room_fee
            hostel_transaction.is_dues = true
          end
          if hostel_transaction.new_record?
            hostel_transaction.save
            student.remove_amount_from_advances(room_fee)
            self.add_log_payment(student.hostel_room_id, student.id, room_fee, hostel_transaction.date)
          else
            hostel_transaction.save
          end
        end 
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
                    start_month: start_month,
                    allow_males: allow_males,
                    allow_females: allow_females
                  })
  end
end
