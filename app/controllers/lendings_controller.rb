class LendingsController < ApplicationController
  before_action :authenticate_user! # ログイン必須
  before_action :set_item, only: [ :create, :update ]

  def index
    @borrowing_items = current_user.lendings.includes(:item).where(returned_at: nil)
  end

  def create
    @lending = @item.lendings.build(lending_params)
    @lending.user = current_user

    @lending.lent_at = Time.current

    # トランザクション: どっちか失敗したら全部キャンセルする安全装置
    ActiveRecord::Base.transaction do
      @lending.save!
      @item.borrowed! # ステータスを「貸出中」に変更
    end

    # 【修正】respond_to を消して、強制的にリダイレクトさせる
    redirect_to item_path(@item), notice: "貸出処理が完了しました"

  rescue ActiveRecord::RecordInvalid => e
    # エラー時はリダイレクト
    redirect_to @item, alert: "貸出失敗: #{e.record.errors.full_messages.join(", ")}"
  end

  def update
    @returning_item = current_user.lendings.find_by(item_id: params[:item_id], returned_at: nil)
    @returning_item.returned_at = Time.current

    # トランザクション: どっちか失敗したら全部キャンセルする安全装置
    ActiveRecord::Base.transaction do
      @returning_item.save!
      @item.available!
    end

    redirect_to item_path(@item), notice: "返却処理が完了しました"

  rescue ActiveRecord::RecordInvalid => e
    # エラー時はリダイレクト
    redirect_to @item, alert: "返却失敗: #{e.record.errors.full_messages.join(", ")}"
  end

  private

  def lending_params
    params.require(:lending).permit(:lent_at, :due_at, :return_at)
  end

  def set_item
    @item = Item.find(params[:item_id])
  end
end
