class Hostel < ActiveRecord::Base
  belongs_to :organisation
  default_scope { where(organisation_id: Organisation.current_id) }    

  def as_json(options = {})
    organisation_id :organisation_id,
    name: name, 
    gender: gender, 
    rooms: rooms, 
    owner: owner, 
    address: address, 
    average_fee: average_fee,
    student_occupancy: student_occupancy,
    is_service_tax: is_service_tax,
    service_tax: service_tax
  end
end
