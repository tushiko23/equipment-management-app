class AddPermissionsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :can_create_admin_users, :boolean, default: false, null: false
    add_column :users, :can_edit_admin_users, :boolean, default: false, null: false
    add_column :users, :can_delete_admin_users, :boolean, default: false, null: false
    add_column :users, :can_create_general_users, :boolean, default: false, null: false
    add_column :users, :can_edit_general_users, :boolean, default: false, null: false
    add_column :users, :can_delete_general_users, :boolean, default: false, null: false
  end
end
