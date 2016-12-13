# class for logic which is used across the entire application.
# all other controllers will inherit from this one.
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

  def current_user_auth
    @current_user_auth ||= UserAuth.find_by(id: session[:user_auth_id])
  end

  def notice_if(condition, notice)
    if condition
      flash[:notice] += notice
      return true
    end
    false
  end

  def require_logged_in
    redirect_to login_path unless current_user_auth
  end

  helper_method :current_user_auth
end
