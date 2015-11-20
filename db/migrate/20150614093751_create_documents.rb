class CreateDocuments < ActiveRecord::Migration
  def change
    create_table :documents do |t|
      t.string :document_file_name
      t.string :document_content_type
      t.string :document_file_size
      t.has_attached_file :document
      t.integer :exam_id, default: nil
      t.timestamps null: false
    end
  end
end
