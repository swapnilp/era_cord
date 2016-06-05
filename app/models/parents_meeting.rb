class ParentsMeeting < ActiveRecord::Base
  
  default_scope { where(organisation_id: Organisation.current_id) }  

  belongs_to :batch

  def self.my_organisation(org_id)
    where(organisation_id: org_id)
  end

  def as_json(options= {})
    options.merge({
                    agenda: agenda,
                    date: date.strftime("%d %b %Y %I:%M %p"),
                    contact_person: contact_person,
                    sms_sent: sms_sent
                  })
    
  end
  
  
end
