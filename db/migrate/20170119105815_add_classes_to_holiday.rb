class AddClassesToHoliday < ActiveRecord::Migration
  def change
    add_column :holidays, :specific_class, :boolean, default: false
    add_column :holidays, :classes, :string
  end
end
