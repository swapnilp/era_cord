class AddTextColorToSubject < ActiveRecord::Migration
  def change
    add_column :subjects, :text_color, :string, default: "#FFF"
  end
end
