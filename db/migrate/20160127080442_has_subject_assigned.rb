class HasSubjectAssigned < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :has_subject_assigned, :boolean, default: false
  end
end
