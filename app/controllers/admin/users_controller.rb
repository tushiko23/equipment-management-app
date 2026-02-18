class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  def index
    if current_user.super_admin?
      @users = User.all
    elsif current_user.admin?
      @users = User.general
    end
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    # 1. まず、越権行為（権限昇格）をブロック！
    if current_user.admin? && !@user.general?
      @user.errors.add(:role, "一般ユーザー以外作成できません")
      render :new, status: :unprocessable_entity
      return # ここで処理をストップ（下のsaveに行かせない）
    end

    if @user.general?
      unless current_user.super_admin? || current_user.can_create_general_users?
        @user.errors.add(:base, "管理者は一般ユーザーのみ作成可能です")
        render :new, status: :unprocessable_entity
        return
      end
    elsif @user.admin?
      unless current_user.super_admin? || current_user.can_create_admin_users?
        @user.errors.add(:base, "管理者は一般ユーザーのみ作成可能です")
        render :new, status: :unprocessable_entity
        return
      end
    elsif @user.super_admin?
      unless current_user.super_admin?
        @user.errors.add(:base, "管理者は一般ユーザーのみ作成可能です")
        render :new, status: :unprocessable_entity
        return
      end
    end

    # 2. 通常のバリデーション（空欄がないか等）と保存
    if @user.save
      redirect_to admin_users_path, notice: "ユーザーが新規作成されました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    #before_actionでユーザー情報を取得
  end

  def edit
    #before_actionでユーザー情報を取得
  end

  def update
    # ▼ ターゲット別の警備員チェック ▼
    if @user.general?
      unless current_user.super_admin? || current_user.can_edit_general_users?
        @user.errors.add(:base, "権限がないため編集できません")
        render :edit, status: :unprocessable_entity
        return
      end
    elsif @user.admin?
      unless current_user.super_admin? || current_user.can_edit_admin_users?
        @user.errors.add(:base, "権限がないため編集できません")
        render :edit, status: :unprocessable_entity
        return
      end
    elsif @user.super_admin?
      unless current_user.super_admin?
        @user.errors.add(:base, "権限がないため編集できません")
        render :edit, status: :unprocessable_entity
        return
      end
    end
    # user_paramsからパスワード関連だけを除外して、updateに渡す！
    update_params = user_params.except(:password, :password_confirmation, :current_password)

    if @user.update(update_params)
      redirect_to admin_user_path(@user), notice: "ユーザー情報を編集しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    # ▼ ターゲット別の警備員チェック ▼
    if @user.general?
      unless current_user.super_admin? || current_user.can_delete_general_users?
        redirect_to admin_users_path, alert: "一般ユーザーを削除する権限がありません"
        return
      end
    elsif @user.admin?
      unless current_user.super_admin? || current_user.can_delete_admin_users?
        redirect_to admin_users_path, alert: "管理ユーザーを削除する権限がありません"
        return
      end
    elsif @user.super_admin?
      redirect_to admin_users_path, alert: "そのユーザーは削除できません"
      return
    end

    @user.destroy
    if @user == current_user
      sign_out(current_user)
      redirect_to root_path, notice: "自身のユーザーを削除しました"
    else
      redirect_to admin_users_path, notice: "ユーザーの削除に成功しました。"
    end
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :role, :avatar, :can_create_admin_users, :can_edit_admin_users, :can_delete_admin_users, :can_create_general_users, :can_edit_general_users, :can_delete_general_users)
    end

    def set_user
      @user = User.find(params[:id])
    end
end
