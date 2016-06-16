class AddClassToParentsMeeting < ActiveRecord::Migration
  def change
    add_column :parents_meetings, :jkci_class_id, :integer
  end
end
