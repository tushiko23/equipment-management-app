class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  def user_after_sing_in_path_for(resource)
    user_path(resource)
  end

  def user_after_sing_out_path_for(resource)
    root_path
  end
end
