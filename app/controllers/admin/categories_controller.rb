class Admin::CategoriesController < Admin::BaseController
  before_action :set_category, only: [ :edit, :update, :destroy ]
  before_action :check_no_items, only: [ :edit, :update ]

  def index
    @categories = Category.all.to_a
    other_category = @categories.find { |c| c.name == "その他" }

    @categories.delete(other_category)
    @categories.push(other_category)
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
      redirect_to admin_categories_path, alert: "備品に紐づいているため削除できません。"
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
end
