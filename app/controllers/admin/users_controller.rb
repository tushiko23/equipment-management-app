class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

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
    # user_paramsからパスワード関連だけを除外して、updateに渡す！
    update_params = user_params.except(:password, :password_confirmation, :current_password)

    if @user.update(update_params)
      redirect_to admin_user_path(@user), notice: "ユーザー情報を編集しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
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
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :role, :avatar)
    end

    def set_user
      @user = User.find(params[:id])
    end
end
