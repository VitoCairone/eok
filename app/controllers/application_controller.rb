class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

    def current_user_auth
      @current_user_auth ||= UserAuth.find_by(id: session[:user_auth_id])
    end

  helper_method :current_user_auth
end