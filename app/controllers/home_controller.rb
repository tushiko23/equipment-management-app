class HomeController < ApplicationController
  def index
    if user_signed_in?
      if current_user.admin? || current_user.super_admin?
        @total_items_count = Item.count
        @borrowed_lendings_count = Lending.where(returned_at: nil).count
        @overdue_lendings = Lending.includes(:user, :item).where(returned_at: nil).where("due_at < ?", Date.current.beginning_of_day)
        @today_lendings = Lending.includes(:user, :item).where(returned_at: nil).where(due_at: Date.current.all_day)
        @active_lendings = Lending.includes(:user, :item).where(returned_at: nil).order(due_at: :asc)
        @borrowing_rate = @total_items_count.zero? ? 0 : (@borrowed_lendings_count.to_f / @total_items_count * 100).round
        @replied_notifications = Notification.where.not(reply_message: nil).where(checked: false).order(updated_at: :desc).limit(5)
      elsif current_user.general?
        @recommended_items = Item.order(created_at: :desc).limit(4)
        @unread_notifications = current_user.notifications.where(read: false).order(created_at: :desc)
      end

      @my_active_lendings = current_user.lendings.where(returned_at: nil).order(due_at: :asc)
    end
  end
end
