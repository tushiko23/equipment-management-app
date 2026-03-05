class NotificationsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_notification, only: [ :update ]

  def create
    @notification = Notification.new(notification_params)

    if @notification.save
      redirect_to root_path, notice: "ユーザーに通知を送信しました！"
    else
      redirect_to root_path, alert: "通知の送信に失敗しました。"
    end
  end

  def update
    @notification = Notification.find(params[:id])

    if params[:notification] && params[:notification][:checked] == "true"
      if @notification.update(checked: true)
        redirect_to root_path, notice: "ユーザーからの返信を「対応済み」にしました！"
      else
        redirect_to root_path, alert: "更新に失敗しました。"
      end

    else
      if @notification.update(notification_params.merge(read: true))
        redirect_to root_path, notice: "通知に返信し、確認済みにしました！"
      else
        redirect_to root_path, alert: "返信に失敗しました。"
      end
    end
  end

  private

  def set_notification
    # 管理者なら全ての通知を探せるが、一般ユーザーは「自分宛の通知」しか探せないようにする
    if current_user.admin?
      @notification = Notification.find_by(id: params[:id])
    else
      @notification = current_user.notifications.find_by(id: params[:id])
    end

    if @notification.nil?
      redirect_to root_path, alert: "権限がありません"
    end
  end

  def notification_params
    params.require(:notification).permit(:user_id, :item_id, :message, :reply_message, :checked)
  end
end
