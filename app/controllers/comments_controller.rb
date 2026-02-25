class CommentsController < ApplicationController
  before_action :set_item
  before_action :set_comment, only: [ :edit, :update, :destroy ]
  def index
    @comment = @item.comments.new
    @comment.user = current_user
    @comments = @item.comments.order(created_at: :desc)
  end

  def create
    @comment = @item.comments.build(comment_params)
    @comment.user = current_user
    if @comment.save
      redirect_to item_comments_path(@item), notice: 'コメントを追加しました'
    else
      redirect_to item_comments_path(@item), alert: 'コメントに失敗しました'
    end
  end

  def edit
    
  end

  def update
    if @comment.update(comment_params)
      redirect_to item_comments_path(@item), notice: 'コメントを更新しました'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @comment.destroy
    respond_to do |format|
      format.html { redirect_to item_comments_path(@item) }
      format.turbo_stream
    end
  end

  private
    def comment_params
      params.require(:comment).permit(:content)
    end

    def set_item
      @item = Item.find(params[:item_id])
    end

    def set_comment
      @comment = @item.comments.find(params[:id])
    end
end
