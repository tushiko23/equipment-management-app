class User < ApplicationRecord
  has_one_attached :avatar

  has_many :lendings, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_items, class_name: "Item"

  enum role: { general: 0, admin: 1 }
  validates :name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
  VALID_PASSWORD_REGEX = /\A(?=.*[a-z])(?=.*\d)[a-z\d]{8,}+\z/

  validates :email,
    presence: true,
    length: { maximum: 255 },
    uniqueness: { case_sensitive: false },
    format: { with: VALID_EMAIL_REGEX, message: "は有効な値を入力してください" }

  validates :password, presence: true, on: :create

  validates :password,
    length: { minimum: 8, maximum: 20 },
    format: { with: VALID_PASSWORD_REGEX },
    allow_blank: true,
    confirmation: true

  validate :avatar_type_and_size_validation

  def image?
    avatar.content_type.in?(%w[image/jpeg image/jpg image/png image/svg+xml])
  end

  def avatar_type_and_size_validation
    return unless avatar.attached?

    if !image?
      errors.add(:avatar, :file_type_not_image)
    end
    # 画像サイズの制限
    if avatar.blob.byte_size > 5.megabytes
      errors.add(:avatar, :file_too_large)
    end
  end
end
