class CreateSubClasses < ActiveRecord::Migration
  def change
    create_table :sub_classes do |t|
      t.string :name
      t.references :jkci_class
      t.string :destription
      t.timestamps null: false
    end
  end
end
