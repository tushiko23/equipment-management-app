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

  validates :avatar, image: true
end
