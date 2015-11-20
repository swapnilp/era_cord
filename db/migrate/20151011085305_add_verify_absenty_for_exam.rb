class AddVerifyAbsentyForExam < ActiveRecord::Migration
  def change
    add_column :exams, :verify_absenty, :boolean, default: false
    add_column :exams, :verify_result, :boolean, default: false
  end
end
