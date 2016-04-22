class AddExamCatlogsCountToClassStudent < ActiveRecord::Migration
  def change
    add_column :class_students, :exam_catlogs_count, :integer, default: 0
    
    ClassStudent.unscoped.find_each.map do |cs| 
      count = ExamCatlog.unscoped.where(student_id: cs.student_id, jkci_class_id: cs.jkci_class_id).count
      cs.update(exam_catlogs_count: count) 
    end
  end
end
