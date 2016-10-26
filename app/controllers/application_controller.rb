class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  private

    def current_user_auth
      @current_user_auth ||= UserAuth.find_by(id: session[:user_auth_id])
      # puts "debug/ current_user_auth"
      puts @current_user_auth
      # puts "/debug"
    end

  helper_method :current_user_auth
end