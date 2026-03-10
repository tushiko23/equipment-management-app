class Admin::ItemsController < Admin::BaseController
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]
  def index
    @items = Item.where(user_id: [ current_user.id, nil ]).includes(:category)

    search_params = params[:q]&.permit!&.to_h || {}

    if search_params[:name_or_category_name_or_tags_name_cont].present?
      keywords = search_params[:name_or_category_name_or_tags_name_cont].split(/[\p{blank}\s]+/)
      search_params[:name_or_category_name_or_tags_name_cont_any] = keywords

      search_params.delete(:name_or_category_name_or_tags_name_cont)
    end

    @q = @items.ransack(search_params)
    @items = @q.result(distinct: true)
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.created_items.build(item_params)

    if @item.state == "borrowed"
      @item.errors.add(:state, "は手動で「貸出中」に設定することはできません")
      render :new, status: :unprocessable_entity
      return
    end

    if @item.save
      redirect_to admin_items_path, notice: "アイテムが新規作成されました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  def edit
  end

  def update
    @item.assign_attributes(item_params)

    if @item.state == "borrowed"
      @item.errors.add(:state, "は手動で「貸出中」に設定することはできません")
      render :edit, status: :unprocessable_entity
      return
    end

    if @item.save
      redirect_to admin_item_path(@item), notice: "アイテムの情報が更新されました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @item.destroy
    redirect_to admin_items_path, notice: "アイテムを削除しました"
  end

  protected

  def item_params
    params.require(:item).permit(:name, :description, :unique_id, :state, :image, :category_id, :tag_names)
  end

  def set_item
    @item = Item.where(user_id: [ current_user.id, nil ]).find(params[:id])
  end
end
