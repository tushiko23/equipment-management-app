class AddReplyMessageToNotifications < ActiveRecord::Migration[7.2]
  def change
    add_column :notifications, :reply_message, :text
  end
end
