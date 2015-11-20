class CreateOrganisationStandards < ActiveRecord::Migration
  def change
    create_table :organisation_standards do |t|
      t.references :organisation
      t.references :standard
      t.boolean :is_active, default: true
      t.timestamps null: false
    end
  end
end
