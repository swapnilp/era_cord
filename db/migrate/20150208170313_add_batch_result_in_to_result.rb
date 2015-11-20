class AddBatchResultInToResult < ActiveRecord::Migration
  def change
    add_column :results, :batch_result_id, :integer
  end
end
