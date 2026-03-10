class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :configure_permitted_parameters, if: :devise_controller?

  def user_after_sing_in_path_for(resource)
    user_path(resource)
  end

  def user_after_sing_out_path_for(resource)
    root_path
  end

  protected
  def configure_permitted_parameters
    # 管理者用のカラムを許可
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :role ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :role ])
  end
end
