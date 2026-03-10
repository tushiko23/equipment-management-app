class Item < ApplicationRecord
  belongs_to :category
  belongs_to :user, optional: true

  has_many :lendings, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :item_tags, dependent: :destroy
  has_many :tags, through: :item_tags

  enum :state, available: 0, borrowed: 1, maintenance: 2
  has_one_attached :image
  validates :name, presence: true
  validates :unique_id, presence: true, uniqueness: true

  validates :image, image: true

  def self.ransackable_attributes(auth_object = nil)
    %w[name tags_name]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  validate :check_duplicate_tags

  def check_duplicate_tags
    return if self.tag_names.nil?
    tags_array = self.tag_names.split(/[\p{blank}\s]+/).compact_blank()
    if tags_array.size != tags_array.uniq.size
      errors.add(:tag_names, "に重複したタグが含まれています")
    end
  end

  attr_accessor :tag_names
  after_save :save_tags

  def save_tags
    return if self.tag_names.nil?

    tags_data = self.tag_names.split(/[\p{blank}\s]+/).compact_blank().uniq
    self.tags = tags_data.map do |tag|
                  Tag.find_or_create_by(name: tag)
                end
  end

  def self.ransackable_attributes(auth_object = nil)
    %w[name]
  end

  def self.ransackable_associations(auth_object = nil)
    %w[category tags]
  end
end
