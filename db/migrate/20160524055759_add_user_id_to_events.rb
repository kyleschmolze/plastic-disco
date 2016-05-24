class AddUserIdToEvents < ActiveRecord::Migration
  def change
    add_column :events, :user_id, :integer
    add_index :events, :user_id
  end
end
