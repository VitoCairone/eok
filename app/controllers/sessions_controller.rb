class SessionsController < ApplicationController
  def create
    begin
      @user_auth = UserAuth.from_omniauth(request.env['omniauth.auth'])
      session[:user_auth_id] = @user_auth.id
      flash[:success] = 'Welcome, #{@user.name}!'
    rescue
      flash[:warning] = 'There was an error trying to authenticate you.'
    end
    redirect_to new_thought_path
  end

  def destroy
    if current_user_auth
      session.delete(:user_auth_id)
      flash[:success] = 'Logged out!'
    end
    redirect_to new_thought_path
  end
end
