class ExamCatlog < ActiveRecord::Base

  belongs_to :exam
  belongs_to :student
  belongs_to :jkci_class

  scope :only_absents, -> {where(is_present: false)}
  scope :only_presents, -> {where(is_present: true)}
  scope :only_remaining, -> {where(is_present: nil)}
  scope :only_results, -> {where("marks is not ?", nil)}
  scope :only_ignored, -> {where("is_ingored is not ?", nil)}
  scope :completed, -> {where("is_present in (?)",  [true, false])}
  
  default_scope { where(organisation_id: Organisation.current_id) }

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

end
