class CreateFeedBacks < ActiveRecord::Migration
  def change
    create_table :feed_backs do |t|
      t.string :email
      t.string :title
      t.text :message
      t.string :medium, null: false, default: 'mobile'
      t.timestamps null: false
    end
  end
end
