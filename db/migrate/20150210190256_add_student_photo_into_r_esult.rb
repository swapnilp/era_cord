class AddStudentPhotoIntoREsult < ActiveRecord::Migration
  def change
    add_column :results, :student_img, :string
  end
end
