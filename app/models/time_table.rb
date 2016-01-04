class TimeTable < ActiveRecord::Base
  belongs_to :jkci_class
  belongs_to :organisation
  belongs_to :sub_class
  has_many :time_table_classes

  default_scope { where(organisation_id: Organisation.current_id) }


  def as_json(options= {})
    options.merge({
                    id: id,
                    class_name: jkci_class.class_name,
                    start_time: start_time,
                    sub_class: sub_class.try(:name)
                  })
  end
  
end
