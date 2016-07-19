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
    if self.jkci_class.is_current_active
      table_classes = self.time_table_classes.where(cwday: date.cwday)
      table_subjects = table_classes.map(&:subject_id)
      daily_classes = self.jkci_class.daily_teaching_points.where("date >= ? && date <= ?", date.to_date, (date+1.day).to_date).map(&:subject_id)
      (table_subjects - daily_classes).each do |subject_id|
        teacher_id = table_classes.where(subject_id: subject_id).first.teacher_id
        off_class = self.jkci_class.off_classes.find_or_create_by({date: date, subject_id: subject_id, cwday: date.cwday, organisation_id: self.organisation_id})
        off_class.teacher_id = teacher_id
        off_class.save
      end
    end
  end
end
