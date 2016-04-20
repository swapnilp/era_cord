class AddTotalPaymentsToClassStudents < ActiveRecord::Migration
  def change
    add_column :class_students, :collected_fee, :float, default: 0

    ClassStudent.unscoped.each do |class_student|
      amount = StudentFee.unscoped.where(student_id: class_student.student_id, jkci_class_id: class_student.jkci_class_id).map(&:amount).sum || 0
      class_student.update_attributes({collected_fee: amount})
    end
  end
end
