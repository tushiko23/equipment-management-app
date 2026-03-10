class CreateItems < ActiveRecord::Migration[7.2]
  def change
    create_table :items do |t|
      t.string :name
      t.string :unique_id
      t.text :description
      t.integer :state
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end
  end
end
