class AddOrganisationToModels < ActiveRecord::Migration
  def change
    add_column :class_catlogs, :organisation_id, :integer
    add_column :class_students, :organisation_id, :integer
    add_column :daily_teaching_points, :organisation_id, :integer
    add_column :documents, :organisation_id, :integer
    add_column :exam_absents, :organisation_id, :integer
    add_column :exam_catlogs, :organisation_id, :integer
    add_column :exam_results, :organisation_id, :integer
    add_column :exams, :organisation_id, :integer
    add_column :jkci_classes, :organisation_id, :integer
    add_column :notifications, :organisation_id, :integer
    add_column :parents_meetings, :organisation_id, :integer
    add_column :sms_sents, :organisation_id, :integer
    add_column :students, :organisation_id, :integer
    add_column :sub_classes, :organisation_id, :integer
    add_column :teachers, :organisation_id, :integer
    add_column :users, :organisation_id, :integer
  end
end
