class ChangeNameToTitle < ActiveRecord::Migration
  def change
    rename_column :events, :name, :title
    rename_column :videos, :name, :title
  end
end
