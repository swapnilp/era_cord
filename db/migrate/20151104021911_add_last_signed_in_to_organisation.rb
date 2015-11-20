class AddLastSignedInToOrganisation < ActiveRecord::Migration
  def change
    add_column :organisations, :last_signed_in, :datetime
  end
end
