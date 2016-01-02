class CreateTimeTables < ActiveRecord::Migration
  def change
    create_table :time_tables do |t|
      t.string :start_time
      t.references :organisation
      t.references :jkci_class
      t.references :sub_class
      t.timestamps null: false
    end
  end
end
