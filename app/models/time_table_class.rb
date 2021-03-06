class TimeTableClass < ActiveRecord::Base
  acts_as_organisation
  
  belongs_to :time_table
  belongs_to :subject
  belongs_to :sub_class
  belongs_to :teacher
  has_one :jkci_class, through: :time_table
  
  attr_accessor :teacher_name

  def self.day_wise_sort
    all.group_by(&:cwday).collect{|key , value| {Date.cwday_day(key) => value.map(&:teacher_time_table_json)}}.reduce Hash.new, :merge
  end

  def clock_time(time)
    if time.present?
      postpix = time > 12 ? 'PM' : 'AM'
      new_time = time > 12 ? (time - 12) : time
      new_time = sprintf('%.2f', new_time).gsub('.', ':')
      new_time = "#{new_time} #{postpix}"
    else
      new_time = ""
    end
    return new_time
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
                    class_name: jkci_class.class_name
                  })
  end

  def verify_json(options = {})
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
                    time_table_id: time_table_id,
                    day: Date.cwday_day(cwday)
                  })
  end

  def calender_json(options = {}, my_standards)
    options.merge({
                    id: id,
                    subject_id: subject_id,
                    name: sub_class_id.present? ? "#{subject.try(:only_std_name)}- #{sub_class.try(:name)}" : subject.try(:only_std_name),
                    color: subject.try(:color),
                    cwday: cwday == 7 ? 0 : cwday,
                    start_time: clock_time(start_time),
                    end_time: clock_time(end_time),
                    slot_type: slot_type,
                    jkci_class_id: time_table.jkci_class_id,
                    my_class: my_standards.include?(subject.try(:standard_id) || 0)
                  })
  end

  def class_rooms_json(options = {})
    options.merge({
                    id: id,
                    sub_class: sub_class.try(:name),
                    subject: subject.try(:std_name),
                    cwday: cwday,
                    start_time: ('%.2f' % start_time.to_f).gsub(".", ":"),
                    end_time: ('%.2f' % end_time.to_f).gsub(".", ":"),
                    class_room: class_room,
                    color: subject.try(:color),
                    teacher: teacher.try(:name),
                    teacher_mobile: teacher.try(:mobile)
                  })
  end

  def teacher_json(options ={})
    options.merge({
                    id: id,
                    class_name: "#{sub_class.try(:class_name) || jkci_class.class_name}",
                    subject: subject.name,
                    division: sub_class.try(:name),
                    start_time: start_time,
                    end_time: end_time,
                    class_room: class_room,
                    color: subject.try(:color)
                  })
  end

  def teacher_time_table_json(options = {})
    options.merge({
                    id: id,
                    name: "#{jkci_class.class_name}  " + (sub_class_id.present? ? "#{subject.try(:name)}-#{sub_class.try(:name)}" : subject.try(:name)),
                    cwday: cwday,
                    start_time: ('%.2f' % start_time.to_f).gsub(".", ":"),
                    end_time: ('%.2f' % end_time.to_f).gsub(".", ":"),
                    sub_class_name: sub_class.try(:name),
                    class_room: class_room,
                    teacher_name: teacher.try(:name),
                    class_name: jkci_class.class_name,
                    subject: subject.try(:name)
                    
                  })
  end

  
  
end
