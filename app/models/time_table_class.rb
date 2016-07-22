class TimeTableClass < ActiveRecord::Base

  belongs_to :time_table
  belongs_to :subject
  belongs_to :organisation
  belongs_to :sub_class
  belongs_to :teacher
  
  default_scope { where(organisation_id: Organisation.current_id) }  
  attr_accessor :teacher_name

  def self.day_wise_sort
    all.group_by(&:cwday).collect{|key , value| {Date.cwday_day(key) => value.as_json}}.reduce Hash.new, :merge
  end

  
  def as_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:name)}-#{sub_class.try(:name)}" : subject.try(:name),
                    color: subject.try(:color),
                    cwday: cwday,
                    start_time: start_time,
                    end_time: end_time,
                    slot_type: slot_type,
                    sub_class_id: sub_class_id,
                    sub_class_name: sub_class.try(:name),
                    class_room: class_room,
                    teacher_id: teacher_id,
                    teacher_name: teacher.try(:name),
                  })
  end

  def calender_json(options = {})
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:only_std_name)}- #{sub_class.try(:name)}" : subject.try(:only_std_name),
                    color: subject.try(:color),
                    cwday: cwday,
                    start_time: start_time,
                    end_time: end_time,
                    slot_type: slot_type,
                    jkci_class_id: time_table.jkci_class_id
                  })
  end

  def class_rooms_json(options = {})
    options.merge({
                    id: id,
                    sub_class: sub_class.try(:name),
                    subject: subject.std_name,
                    class_room: class_room,
                    cwday: cwday,
                    start_time: start_time,
                    end_time: end_time,
                    class_room: class_room,
                    color: subject.try(:color),
                  })
  end
end
