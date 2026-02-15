class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :check_admin

  layout 'admin'

  private

  def check_admin
    unless current_user&.admin?
      redirect_to root_path, alert: '権限がありません。'
    end
  end
end
