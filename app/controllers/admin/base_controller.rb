class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout "application"

  private

  def check_admin
    if current_user.nil? || current_user.general?
      redirect_to root_path, alert: "権限がありません。"
    end
  end
end
