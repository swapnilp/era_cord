class TimeTable < ActiveRecord::Base
  belongs_to :jkci_class
  belongs_to :organisation
  belongs_to :sub_class
  has_many :time_table_classes

  default_scope { where(organisation_id: Organisation.current_id) }
  
end
