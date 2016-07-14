class DefaultNilTiEmailCodeGteacher < ActiveRecord::Migration
  def change
    change_column :g_teachers, :email_code, :string, default: nil
    change_column :g_teachers, :mobile_code, :string, default: nil
  end
end
