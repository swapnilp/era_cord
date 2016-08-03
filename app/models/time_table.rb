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
    #if self.jkci_class.is_current_active
    #  table_classes = self.time_table_classes.where(cwday: date.cwday)
    #  table_subjects = table_classes.map(&:subject_id)
    #  daily_classes = self.jkci_class.daily_teaching_points.where("date >= ? && date <= ?", date.to_date, (date+1.day).to_date).map(&:subject_id)
    #  (table_subjects - daily_classes).each do |subject_id|
    #    table_class = table_classes.where(subject_id: subject_id).first
    #    off_class = self.jkci_class.off_classes.find_or_create_by({date: date, subject_id: subject_id, cwday: date.cwday, organisation_id: self.organisation_id})
    #    off_class.teacher_id = teacher_id
    #    off_class.save
    #  end
    #end

    if self.jkci_class.is_current_active
      #table_classes = self.time_table_classes.where(cwday: date.cwday)
      #table_subjects = table_classes.map(&:subject_id)
      daily_classes = self.jkci_class.daily_teaching_points.where("date >= ? && date < ?", date.to_date.database_time, (date+1.day).to_date.database_time)
      exams = self.jkci_class.exams.where("exam_date >= ? && exam_date < ?", date.to_date.database_time, (date+1.day).to_date.database_time)
      self.time_table_classes.where(cwday: date.cwday).each do |tt_class|
        if tt_class.sub_class_id.present?
          exams = exams.where("sub_classes like '%,?,%' OR  sub_classes like ?", tt_class.sub_class_id, '')
        end
        exams = exams.where(subject_id: tt_class.subject_id)
        daily_classes = daily_classes.where(subject_id: tt_class.subject_id)
        if (exams.count + daily_classes.count) == 0
          off_class = self.jkci_class.off_classes.find_or_initialize_by({date: date, subject_id: tt_class.subject_id, cwday: date.cwday, organisation_id: self.organisation_id, sub_class_id: tt_class.sub_class_id})
          off_class.teacher_id = tt_class.teacher_id
          off_class.save
        end
      end
    end
  end
end
