class ActivityLog < ActiveRecord::Base
  self.inheritance_column = 'type'
  class << self
    def exam_log(exam_id, action, org_id)
      new(type: "ExamLog", obj_id: exam_id, organisation_id: org_id)
    end
    
    def cources_log
    end
    
    def daily_teaches_log
    end
    
    def off_class_log
    end
    
    def manage_class_log
    end
    
    def teacher_log
    end
  end
  
end

class ExamLog < ActivityLog
  
end
