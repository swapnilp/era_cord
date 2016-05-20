class AddBatchIdToClassStudent < ActiveRecord::Migration
  def change
    add_column :class_students, :batch_id, :integer

    Organisation.current_id = Organisation.all.map(&:id)
    ClassStudent.all.each do |cs|
      cs.update_attributes({batch_id: cs.jkci_class.batch_id})
    end
  end
end
