class Category < ApplicationRecord
  has_many :items, dependent: :restrict_with_error
  validates :name, presence: true, uniqueness: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end
end
