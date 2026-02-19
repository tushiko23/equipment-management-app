class AddUniqueIndexToTagsName < ActiveRecord::Migration[7.2]
  def change
    add_index :tags, :name, unique: true
  end
end
