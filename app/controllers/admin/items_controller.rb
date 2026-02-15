class Admin::ItemsController < Admin::BaseController
  before_action :set_item, only: [ :show, :edit, :update, :destroy ]
  def index
    @items = current_user.created_items.includes(:category)
  end

  def new
    @item = Item.new
  end

  def create
    @item = current_user.created_items.build(item_params)

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
    if @item.update(item_params)
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
    params.require(:item).permit(:name, :description, :unique_id, :state)
  end

  def set_item
    @item = current_user.created_items.find(params[:id])
  end
end
