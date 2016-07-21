class RemoveDeviseFromGTeacher < ActiveRecord::Migration
  def change
    remove_column :g_teachers, :provider
    remove_column :g_teachers, :device_id
    remove_column :g_teachers, :tokens
    remove_column :g_teachers, :token_expires_at
    remove_column :g_teachers, :mpin
    remove_column :g_teachers, :encrypted_password
    remove_column :g_teachers, :reset_password_token
    remove_column :g_teachers, :reset_password_sent_at
    remove_column :g_teachers, :remember_created_at
    remove_column :g_teachers, :sign_in_count
    remove_column :g_teachers, :current_sign_in_at
    remove_column :g_teachers, :last_sign_in_at
    remove_column :g_teachers, :current_sign_in_ip
    remove_column :g_teachers, :last_sign_in_ip
  end
end
