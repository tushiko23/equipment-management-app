class ItemsController < ApplicationController
  def index
    @items = Item.includes(:category).all

    search_params = params[:q]&.permit!&.to_h || {}

    if search_params[:name_or_category_name_or_tags_name_cont].present?
      keywords = search_params[:name_or_category_name_or_tags_name_cont].split(/[\p{blank}\s]+/)
      search_params[:name_or_category_name_or_tags_name_cont_any] = keywords

      search_params.delete(:name_or_category_name_or_tags_name_cont)
    end

    @q = @items.ransack(search_params)
    @items = @q.result(distinct: true)
  end

  def show
    @item = Item.find(params[:id])
  end
end
