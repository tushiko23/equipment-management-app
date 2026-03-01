class User < ApplicationRecord
  has_one_attached :avatar

  has_many :lendings, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :comments, dependent: :destroy
  has_many :created_items, class_name: "Item", dependent: :nullify

  enum :role, general: 0, admin: 1, super_admin: 2
  validates :name, presence: true
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable

  def self.ransackable_attributes(auth_object = nil)
    %w[name email]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  def editable_by?(is_user)
    (is_user.super_admin?) ||
    (is_user.can_edit_admin_users? && self.admin?) ||
    (is_user.can_edit_general_users? && self.general?)
  end

  def deletable_by?(is_user)
    return false if self.super_admin?
    is_user.super_admin? ||
    (is_user.can_delete_admin_users? && self.admin?) ||
    (is_user.can_delete_general_users? && self.general?)
  end


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

  # 一般ゲスト
  def self.guest
    find_or_create_by!(email: 'guest@example.com') do |user|
    # ランダムな小文字8文字と数字2文字をシャッフルして生成したパスワード
      random_password = (('a'..'z').to_a.sample(8) + ('0'..'9').to_a.sample(2)).shuffle.join
      user.password = random_password
      user.name = "一般ゲスト"
    end
  end

  # 管理者ゲスト
  def self.admin_guest
    find_or_create_by!(email: "admin_guest@example.com") do |user|
    # ランダムな小文字8文字と数字2文字をシャッフルして生成したパスワード
      random_password = (("a".."z").to_a.sample(8) + ("0".."9").to_a.sample(2)).shuffle.join
      user.password = random_password
      user.name = "管理者ゲスト"
      user.role = :admin
    end
  end

  def guest?
    self.email == "guest@example.com" || self.email == "admin_guest@example.com"
  end
end
