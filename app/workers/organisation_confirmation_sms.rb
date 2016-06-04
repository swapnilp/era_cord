class OrganisationConfirmationSms < Struct.new(:organisation)
  include SendingSms
  def perform
    send_sms(organisation)
  end

  def send_sms(organisation)
    if organisation.present?
    
      url = organisation[0]
      message = organisation[1]
      obj_id = organisation[2]
      number = organisation[3]

      deliver_sms(URI::encode(url))
      SmsSent.new({obj_type: "organisation_conf", obj_id: obj_id, message: message, is_parent: true, organisation_id: nil, number: number}).save
    end
  end
end
#Delayed::Job.enqueue OrganisationRegistationSms.new(DailyTeachingPoint.last)
