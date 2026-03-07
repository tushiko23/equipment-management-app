class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [ :edit, :update, :destroy ]
  before_action :check_no_items, only: [ :edit, :update ]
  before_action :search_category, only: [ :index,  :new, :edit ]

  def index
  end

  def new
    @category = Category.new
  end

  def create
    @category = Category.new(categories_params)

    if @category.save
      redirect_to admin_categories_path, notice: "カテゴリーが新規作成されました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @category.update(categories_params)
      redirect_to admin_categories_path, notice: "カテゴリーが更新されました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @category.destroy
      redirect_to admin_categories_path, notice: "カテゴリーが削除されました"
    else
      redirect_to admin_categories_path, alert: "アイテムに紐づいているため削除できません。"
    end
  end

  private

  def categories_params
    params.require(:category).permit(:name)
  end

  def set_category
    @category = Category.find(params[:id])
  end

  def check_no_items
    if @category.items.any?
      redirect_to admin_categories_path, alert: "カテゴリー一覧を参照してください"
    end
  end

  def search_category
    search_params = params[:q]&.permit!&.to_h || {}

    if search_params[:name_cont].present?
      keywords = search_params[:name_cont].split(/[\p{blank}\s]+/)
      search_params[:name_cont_any] = keywords
      search_params.delete(:name_cont)
    end

    @q = Category.all.ransack(search_params)
    searched_categories = @q.result(distinct: true).to_a

    other_category = searched_categories.find { |c| c.name == "その他" }

    if other_category
      searched_categories.delete(other_category)
      searched_categories.push(other_category)
    end

    @categories = searched_categories
  end
end
