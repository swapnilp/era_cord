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
  
  
  def calculate_off_class(date)
    time_table_classes = self.time_table_classes.where(cwday: date.cwday).map(&:subject_id)
    daily_classes = self.jkci_class.daily_teaching_points.where("date >= ? && date <= ?", date.to_date, (date+1.day).to_date).map(&:subject_id)
    (time_table_classes - daily_classes).each do |subject_id|
      self.jkci_class.off_classes.build({date: date, subject_id: subject_id, cwday: date.cwday}).save
      
    end
  end
end
