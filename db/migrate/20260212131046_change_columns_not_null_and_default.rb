class ChangeColumnsNotNullAndDefault < ActiveRecord::Migration[7.2]
  def change
    change_column :items, :state, :integer, null: false, default: 0
    change_column :items, :unique_id, :string, null: false
    change_column :notifications, :read, :boolean, null: false, default: false
  end
end
