class ExamCatlog < ActiveRecord::Base
  acts_as_organisation
  belongs_to :exam
  belongs_to :student
  belongs_to :jkci_class
  belongs_to :class_student,->(exam_catlog) {where("jkci_class_id = ?", exam_catlog.jkci_class_id)}, :foreign_key => :student_id, primary_key: :student_id, :counter_cache => true

  scope :only_absents, -> {where(is_present: false)}
  scope :only_presents, -> {where(is_present: true)}
  scope :only_remaining, -> {where(is_present: nil)}
  scope :only_results, -> {where("marks is not ?", nil)}
  scope :only_ignored, -> {where("is_ingored is not ?", nil)}
  scope :completed, -> {where("is_present in (?)",  [true, false])}

  

  def exam_report
    r_name = "#{exam.name} "
    if exam.marks.present?
      r_name << "  |  marks - #{marks || 'not available'}/#{exam.marks}"
    end
    if is_recover
      r_name << " | Recovered"
    end
    r_name
    
  end

  def is_absent?
    return self.is_present == false
  end

  def make_percentage
    if marks.present? && self.marks.present?
      self.update(percentage: ((marks / exam.marks)*100))
    end
  end

  def student_info_json(options = {})
    options.merge({
                    id: id,
                    date: self.exam.try(:exam_date).present? ? self.exam.exam_date.strftime("%b %d-%Y") : "",
                    marks: marks,
                    is_present: is_present,
                    absent_sms_sent: absent_sms_sent,
                    name: exam.try(:std_subject_name)
                  })
  end
  
end
