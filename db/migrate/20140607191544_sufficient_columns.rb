class SufficientColumns < ActiveRecord::Migration
  def change
    add_column :exams, :name, :string
    add_column :students, :is_active, :boolean, default: true
    add_column :exams, :is_active, :boolean, default: true
  end
end
