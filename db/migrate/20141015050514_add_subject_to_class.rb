class AddSubjectToClass < ActiveRecord::Migration
  def change
    add_column :jkci_classes, :subject_id, :integer
  end
end
