class CreateOffClasses < ActiveRecord::Migration
  def change
    create_table :off_classes do |t|
      t.references :jkci_class
      t.references :sub_class
      t.date :date
      t.references :subject
      t.integer :cwday
      t.timestamps null: false
    end
  end
end
