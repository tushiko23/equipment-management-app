class Users::SessionsController < Devise::SessionsController
  # 一般ゲストログインのアクション
  def guest_sign_in
    user = User.guest
    sign_in user
    redirect_to root_path, notice: "一般ゲストユーザーとしてログインしました。"
  end

  # 管理者ゲストログインのアクション
  def admin_guest_sign_in
    user = User.admin_guest
    sign_in user
    redirect_to root_path, notice: "管理者ゲストユーザーとしてログインしました。"
  end
end
