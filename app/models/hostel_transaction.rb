class HostelTransaction < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :hostel
  belongs_to :hostel_room
  belongs_to :student
  has_many :hostel_transactions
  
  
  def student_payment_info_json(options = {})
    options.merge({
                    id: id,
                    hostel: hostel.name,
                    hostel_room: hostel_room.name,
                    amount: amount,
                    date: date.strftime("%B-%Y"),
                    is_dues: is_dues
                  })
  end

  def get_dues_from_advances

  end
end
