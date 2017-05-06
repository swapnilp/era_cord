class MeetingsStudent < ActiveRecord::Base
  acts_as_organisation
  belongs_to :student
  belongs_to :organisation
  belongs_to :parents_meeting

  

  def as_json(options = {})
    options.merge({
                    name: student.try(:name),
                    mobile: mobile,
                    sent_sms: sent_sms
                    
                  })
  end
end
