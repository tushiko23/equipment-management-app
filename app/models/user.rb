class User < ApplicationRecord
  has_one_attached :avatar
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
    format: { with: VALID_PASSWORD_REGEX, message: "は8文字以上20字以内で入力してください" },
    allow_blank: true,
    confirmation: true
end
