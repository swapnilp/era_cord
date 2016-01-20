class OffClass < ActiveRecord::Base
  
  belongs_to :subject
  belongs_to :jkci_class

  default_scope { where(organisation_id: Organisation.current_id) }  
  
  def calendar_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: subject.try(:std_name),
                    color: subject.try(:color),
                    cwday: cwday,
                    date: date.to_time,
                    jkci_class_id: jkci_class_id
                  })
  end
  
end
