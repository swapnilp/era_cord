class AddAdharCardToStudent < ActiveRecord::Migration
  def change
    add_column :students, :adhar_card, :string
  end
end
