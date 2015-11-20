class AddCreateVerificationToExam < ActiveRecord::Migration
  def change
    add_column :exams, :create_verification , :boolean, default: false
  end
end
