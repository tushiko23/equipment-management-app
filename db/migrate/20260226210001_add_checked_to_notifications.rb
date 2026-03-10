class AddCheckedToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :checked, :boolean, default: false, null: false
  end
end
