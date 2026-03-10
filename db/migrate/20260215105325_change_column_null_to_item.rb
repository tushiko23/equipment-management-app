class ChangeColumnNullToItem < ActiveRecord::Migration[7.2]
  def change
    change_column_null :items, :user_id, false
  end
end
