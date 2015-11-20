class CreateSmsSents < ActiveRecord::Migration
  def change
    create_table :sms_sents do |t|
      t.text :number
      t.string :obj_type
      t.integer :obj_id
      t.text :message
      t.boolean :is_parent 
      t.timestamps
    end
  end
end
