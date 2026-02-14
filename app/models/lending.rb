class Lending < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :lent_at, presence: true
end
