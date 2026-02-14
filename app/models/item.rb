class Item < ApplicationRecord
  belongs_to :category

  has_many :lendings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :item_tags, dependent: :destroy
  has_many :tags, through: :item_tags

  enum state: { available: 0, borrowed: 1, maintenance: 2 }
  validates :name, presence: true
  validates :unique_id, presence: true, uniqueness: true
end
