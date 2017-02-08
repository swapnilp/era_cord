class CreateVendors < ActiveRecord::Migration
  def change
    create_table :vendors do |t|
      t.string :name
      t.string :nick_name
      t.string :cheque_name
      t.string :ac_no
      t.string :bank
      t.string :address
      t.string :reason
      t.references :organisation
      t.timestamps null: false
    end
  end
end
