class Lending < ApplicationRecord
  belongs_to :user
  belongs_to :item

  validates :lent_at, presence: true

  validates :due_at, comparison: { greater_than_or_equal_to: -> { Time.zone.now.beginning_of_day } }
  validate :item_must_not_be_currently_borrowed, on: :create

  private

  def item_must_not_be_currently_borrowed
    return if item.blank?

    if item.lendings.where(returned_at: nil).exists?
      errors.add(:base, "このアイテムは現在他の人が借りています")
    end
  end

  validates :returned_at, comparison: { greater_than_or_equal_to: :lent_at }, allow_nil: true

  validate :item_must_be_available, on: :create
  private

  def item_must_be_available
    return if item.blank?
    unless item.available?
      errors.add(:item, "は現在貸出中のため、新しく借りることはできません")
    end
  end
end
