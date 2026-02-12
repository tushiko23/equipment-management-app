class AddColumnsToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :role, :integer, null: false, default: 0
    add_column :users, :uid, :string
    add_column :users, :provider, :string

    add_index :users, [ :uid, :provider ], unique: true
  end
end
