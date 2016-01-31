class AddIsStudentVerifiedToJkciClasses < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :is_student_verified, :boolean, default: false
  end
end
