class AddPublishDateToExam < ActiveRecord::Migration
  def change
    add_column :exams, :published_date, :datetime
  end
end
