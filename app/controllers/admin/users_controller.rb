class Admin::UsersController < Admin::BaseController
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
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    # user_paramsからパスワード関連だけを除外して、updateに渡す！
    update_params = user_params.except(:password, :password_confirmation, :current_password)

    if @user.update(update_params)
      redirect_to admin_user_path(@user), notice: "ユーザー情報を編集しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
  end

  private
    def user_params
      params.require(:user).permit(:email, :password, :password_confirmation, :name, :role, :avatar)
    end
end
