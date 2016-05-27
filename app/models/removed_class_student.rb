class RemovedClassStudent < ActiveRecord::Base
  belongs_to :jkci_class
  belongs_to :student

  def self.add_removed_class_students(class_students)
    if class_students.is_a?(Array)
      class_students.each do |class_student|
        add_removed_class_student(class_student)
      end
    else
      add_removed_class_student(class_students)
    end
  end

  def self.add_removed_class_student(class_student)
    if true#class_student.created_at < Date.today - 1.month
      
      removed_class_student = RemovedClassStudent.find_or_initialize_by({student_id: class_student.student_id, organisation_id: class_student.organisation_id, batch_id: class_student.batch_id, jkci_class_id: class_student.jkci_class_id})
      removed_class_student.collected_fee = class_student.collected_fee
      removed_class_student.save
    end
  end

  def accounts_json(options = {})
    options.merge({
                    name: student.name, 
                    p_mobile: student.p_mobile,
                    jkci_class: jkci_class.try(:class_name),
                    student_id: student_id,
                    collected_fee: collected_fee,
                    remaining_fee: jkci_class.try(:fee) || 0 - collected_fee,
                    total_transactions: 0
                  })
  end
  
  def fee_info_json(options = {})
    options.merge({
                    id: id,
                    student_id: student_id,
                    class_id: jkci_class_id,
                    class_name: jkci_class.class_name,
                    remaining_fee: jkci_class.fee - collected_fee
                  })
  end
end
