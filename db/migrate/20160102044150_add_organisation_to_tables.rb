class AddOrganisationToTables < ActiveRecord::Migration
  def change
    add_column :student_subjects, :organisation_id, :integer
    add_column :exam_points, :organisation_id, :integer
  end
end
