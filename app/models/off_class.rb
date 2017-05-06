class OffClass < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :subject
  belongs_to :jkci_class
  belongs_to :sub_class
  belongs_to :teacher

  
  def calendar_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:std_name)}-#{sub_class.try(:name)}" : subject.try(:std_name),
                    color: subject.try(:color),
                    cwday: cwday,
                    date: date.to_time,
                    jkci_class_id: jkci_class_id,
                    teacher_id: teacher_id,
                    teacher_name: teacher.try(:name)
                  })
  end

  def as_json(options = {})
    options.merge({
                    id: id,
                    name: sub_class_id.present? ? "#{subject.try(:std_name)}-#{sub_class.try(:name)}" : subject.try(:std_name),
                    date: date.to_date,
                    teacher_name: teacher.try(:name)
                  })
  end
  
end
