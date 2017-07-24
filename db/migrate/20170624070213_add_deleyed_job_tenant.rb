class AddDeleyedJobTenant < ActiveRecord::Migration
  def change
    add_column :delayed_jobs, :organisation_id, :integer
  end
end
