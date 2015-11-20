class CreatePromotionalMails < ActiveRecord::Migration
  def change
    create_table :promotional_mails do |t|

      t.string :mails
      t.string :msg
      t.string :subject
      t.timestamps null: false
    end
  end
end
