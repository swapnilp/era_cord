class AddMobileCodeAndEmailCodeToGTeachers < ActiveRecord::Migration
  def change
    add_column :g_teachers, :mobile_code, :string, default: ""
    add_column :g_teachers, :email_code, :string, default: ""
  end
end
