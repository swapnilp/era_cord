class AddVerificationRequiredIntoNotification < ActiveRecord::Migration
  def change
    add_column :notifications, :verification_require, :boolean, default: false
  end
end
