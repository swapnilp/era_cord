class TimeTableClass < ActiveRecord::Base

  belongs_to :time_table
  belongs_to :subject
  belongs_to :organisation
  belongs_to :sub_class
  
  default_scope { where(organisation_id: Organisation.current_id) }  

  def as_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:name)}-#{sub_class.try(:name)}" : subject.try(:name),
                    color: subject.try(:color),
                    cwday: cwday,
                    start_time: start_time.gsub(":", '.').to_f,
                    end_time: end_time.gsub(":", '.').to_f,
                    slot_type: slot_type,
                    sub_class_id: sub_class_id,
                    sub_class_name: sub_class.try(:name)
                  })
  end

  def calender_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:std_name)}- #{sub_class.try(:name)}" : subject.try(:std_name),
                    color: subject.try(:color),
                    cwday: cwday,
                    start_time: start_time,
                    end_time: end_time,
                    slot_type: slot_type
                  })
  end
end
