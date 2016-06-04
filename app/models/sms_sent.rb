class SmsSent < ActiveRecord::Base
  include ActiveSupport::Inflector
  #self.inheritance_column = :obj_type

  belongs_to :student

  after_save :update_record


  scope :our_organisations, -> { where(organisation_id: Organisation.current_id, obj_type: ["Activation", "absent_exam", "exam result", "exam_result", "group_exam_result", "activation_sms", "student_fee"]) }
  

  def update_record
    if self.obj_type == "absent_exam"
      exam_catlog = ExamCatlog.unscoped.where(id: obj_id).first
      exam_catlog.update_attributes({absent_sms_sent: true})
    end
    if self.obj_type == "exam_result"
      exam_catlog = ExamCatlog.unscoped.where(id: obj_id).first
      exam_catlog.update_attributes({absent_sms_sent: true})
    end
    if self.obj_type == "daily_teach_sms"
      class_catlog = ClassCatlog.unscoped.where(id: obj_id).first
      class_catlog.update_attributes({sms_sent: true})
    end
    if self.obj_type == "group_exam_result"
      ids = Exam.unscoped.where(ancestry: obj_id.to_s).map(&:id)
      exam_catlog = ExamCatlog.unscoped.where(exam_id: ids, student_id: student_id)
      exam_catlog.update_all({absent_sms_sent: true})
    end
  end

  def self.my_organisation(org_id)
    where(organisation_id: org_id)
  end

  def as_json(options= {})
    options.merge({
                    obj_type: humanize(obj_type),
                    message: message,
                    is_parent: is_parent,
                    student_name: student.try(:name),
                    number: number
                  })
  end
  
end
