class CreateLendings < ActiveRecord::Migration[7.2]
  def change
    create_table :lendings do |t|
      t.datetime :lent_at
      t.datetime :due_at
      t.datetime :returned_at
      t.references :user, null: false, foreign_key: true
      t.references :item, null: false, foreign_key: true

      t.timestamps
    end
  end
end
