class Notification < ActiveRecord::Base
  
  default_scope { where(organisation_id: Organisation.current_id) }  
  scope :pending, -> { where(is_completed: [nil, false], verification_require: true )}

  def self.add_create_exam(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam.present?
      org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Exam #{exam.name} is created. Please verify Exam", url: "/exams/#{obj_id}?&notification=true", actions: "create_exam", verification_require: true, jkci_class_id: exam.jkci_class_id}).save
    end
  end
  
  def self.verified_exam(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam.present?
      pre_notification = exam.notifications.where(actions: "create_exam").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      if exam.is_group
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Exam #{exam.name} is verified. Please conduct all exams and publish it ", url: "/exams/#{obj_id}?&notification=true", actions: "verify_exam", jkci_class_id: exam.jkci_class_id}).save
      else
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Exam #{exam.name} is verified. Please conduct exam ", url: "/exams/#{obj_id}?&notification=true", actions: "verify_exam", jkci_class_id: exam.jkci_class_id}).save
      end
    end
  end

  def self.exam_conducted(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam.present?
      pre_notification = exam.notifications.where(actions: "verify_exam").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Exam #{exam.name} is conducted. Please add absenty & marks", url: "/exams/#{obj_id}?&notification=true", actions: "exam_conduct", jkci_class_id: exam.jkci_class_id}).save
    end
  end
  
  def self.add_exam_abesnty(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam
      pre_notification = exam.notifications.where(actions: "exam_conduct").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      notification = exam.notifications.where(actions: "add_exam_absenty").first
      exam.notifications.where(actions: "verify_exam_absenty").destroy_all
      if notification.present?
        notification.update_attributes({is_completed: false})
      else
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Absenty is added for exam #{exam.name}. Please verify absenty", url: "/exams/#{obj_id}?&notification=true", actions: "add_exam_absenty", verification_require: true, jkci_class_id: exam.jkci_class_id}).save
      end
    end
  end

  def self.verify_exam_abesnty(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam 
      pre_notification = exam.notifications.where(actions: "add_exam_absenty").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      notification = exam.notifications.where(actions: "verify_exam_absenty").first
      if notification.present?
        notification.update_attributes({is_completed: false})
      else
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Absenty is verified for exam #{exam.name}. Exam might be in publish mode.", url: "/exams/#{obj_id}?&notification=true", actions: "verify_exam_absenty", jkci_class_id: exam.jkci_class_id}).save
      end
    end
  end
  
  def self.add_exam_result(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam
      pre_notification = exam.notifications.where(actions: "exam_conduct").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      exam.notifications.where(actions: "verify_exam_result").destroy_all
      notification = exam.notifications.where(actions: "add_exam_result").first
      if notification.present?
        notification.update_attributes({is_completed: false})
      else
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Result has been added for exam #{exam.name}. Please verify marks.", url: "/exams/#{obj_id}?&notification=true", actions: "add_exam_result", verification_require: true, jkci_class_id: exam.jkci_class_id}).save
      end
    end
  end

  def self.verify_exam_result(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam 
      pre_notification = exam.notifications.where(actions: "add_exam_result").first
      pre_notification.update_attributes({is_completed: true}) if pre_notification
      notification = exam.notifications.where(actions: "verify_exam_result").first
      if notification.present?
        notification.update_attributes({is_completed: false})
      else
        org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Result has been verified for exam #{exam.name}. Please Publish Exam", url: "/exams/#{obj_id}?&notification=true", actions: "verify_exam_result", jkci_class_id: exam.jkci_class_id}).save
      end
    end
  end

  def self.publish_exam(obj_id, org)
    exam = org.exams.where(id: obj_id).first
    if exam 
      pre_notification = exam.notifications.where(actions: ["verify_exam_result", "verify_exam_absenty"])
      pre_notification.update_all({is_completed: true}) if pre_notification.present?
      org.notifications.build({object_type: "Exam", object_id: obj_id, message: "Exam #{exam.name} is published", url: "/exams/#{obj_id}?&notification=true", actions: "publish_exam", jkci_class_id: exam.jkci_class_id}).save
    end
  end

  def self.add_daily_teaches(obj_id, org)
    dtp = DailyTeachingPoint.where(id: obj_id).first
    if dtp
      org.notifications.build({object_type: "DailyTeaching_point", object_id: obj_id, message: "Daily Teaches is created for #{dtp.jkci_class.class_name}", url: "/daily_teachs/#{obj_id}?&notification=true", jkci_class_id: dtp.jkci_class_id}).save
    end
  end

  def self.create_daily_teaches(obj_id, org)
    dtp = DailyTeachingPoint.where(id: obj_id).first
    if dtp
    end
  end
  
  def self.add_daily_teaches_adsenty(obj_id, org)
    dtp = DailyTeachingPoint.where(id: obj_id).first
    if dtp
      org.notifications.build({object_type: "DailyTeaching_point", object_id: obj_id, message: "Added absenty for  #{dtp.jkci_class.class_name}", url: "/daily_teachs/#{obj_id}?&notification=true", jkci_class_id: dtp.jkci_class_id}).save
    end
  end

  def self.publish_daily_teaches_absenty(obj_id, org)
    dtp = DailyTeachingPoint.where(id: obj_id).first
    if dtp
      org.notifications.build({object_type: "DailyTeaching_point", object_id: obj_id, message: "Publish absenty for  #{dtp.jkci_class.class_name}", url: "/daily_teachs/#{obj_id}?&notification=true", jkci_class_id: dtp.jkci_class_id}).save
    end
  end

  def as_json(options = {})
    options.merge({
                    id: id,
                    message: message,
                    object_type: object_type,
                    object_id: object_id,
                    url: url
                  })
  end
end
