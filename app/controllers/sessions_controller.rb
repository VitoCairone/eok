class SessionsController < ApplicationController
  def create
    begin
      @user_auth = UserAuth.from_omniauth(request.env['omniauth.auth'])
      session[:user_auth_id] = @user_auth.id
      flash[:success] = 'Welcome, #{@user.name}!'
    rescue
      flash[:warning] = 'There was an error trying to authenticate you.'
    end

    # puts "@@@@@"
    # puts @user_auth.newbie
    # puts session[:return_to]
    if @user_auth.newbie
      @user_auth.newbie = false
      @user_auth.save
      redirect_to welcome_path
    else
      if session[:return_to]
        redirect_back
      else
        redirect_to questions_path
      end
    end
  end

  def destroy
    if current_user_auth
      session.delete(:user_auth_id)
      flash[:success] = 'Logged out!'
    end
    redirect_to new_thought_path
  end

  def redirect_back
    redirect_to session[:return_to]
  end
end
