class ActivityLog < ActiveRecord::Base
  self.inheritance_column = 'type'
  class << self
    def exam_log(exam_id, action, org_id, email)
      new(type: "ExamLog", obj_id: exam_id, organisation_id: org_id, user_email_id: email, reason: action).save
    end
    
    def course_log(action, org_id, email)
      new(type: "CourseLog", organisation_id: org_id, user_email_id: email, reason: action).save
    end
    
    def daily_teach_log(dtp_id, action, org_id, email)
      new(type: "DailyTeachLog", obj_id: dtp_id, organisation_id: org_id, user_email_id: email, reason: action).save
    end
    
    def off_class_log(off_class_id, action, org_id, email)
      new(type: "OffClassLog", obj_id: off_class_id, organisation_id: org_id, user_email_id: email, reason: action).save
    end
    
    def manage_class_log(class_id, action, org_id, email)
      new(type: "ManageClassLog", obj_id: class_id, organisation_id: org_id, user_email_id: email, reason: action).save
    end
    
    def teacher_log(teacher_id, action, org_id, email)
      new(type: "TeacherLog", obj_id: teacher_id, organisation_id: org_id, user_email_id: email, reason: action).save
    end
  end
end

class ExamLog < ActivityLog
end

class CourseLog < ActivityLog
end

class DailyTeachLog < ActivityLog
end

class OffClassLog < ActivityLog
end

class ManageClass < ActivityLog
end

class TeacherLog < ActivityLog
end
