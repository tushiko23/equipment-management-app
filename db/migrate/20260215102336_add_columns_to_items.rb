class AddColumnsToItems < ActiveRecord::Migration[7.2]
  def change
    add_reference :items, :user, foreign_key: true
  end
end
