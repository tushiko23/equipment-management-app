class RenameMassageToMessageInNotifications < ActiveRecord::Migration[7.2]
  def change
    rename_column :notifications, :massage, :message
  end
end
