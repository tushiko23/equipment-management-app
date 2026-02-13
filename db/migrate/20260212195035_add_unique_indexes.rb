class AddUniqueIndexes < ActiveRecord::Migration[7.2]
  def change
    add_index :items, :unique_id, unique: true
    add_index :item_tags, [ :item_id, :tag_id ], unique: true
  
    change_column_null :categories, :name, false
    change_column_null :items, :name, false
    change_column_null :tags, :name, false
    change_column_null :comments, :content, false
    change_column_null :lendings, :lent_at, false
  end
end
