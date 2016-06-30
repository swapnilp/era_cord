class AddOrganisaitonIdToTeacherSubject < ActiveRecord::Migration
  def change
    add_column :teacher_subjects, :organisation_id, :integer
  end
end
