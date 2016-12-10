# Controls the logic for Sessions,
# which are routes handling user identification and authorization
# there is no Session model or table
class SessionsController < ApplicationController
  def create
    create_or_find_user_by_omniauth
    
    if @user_auth.newbie
      @user_auth.newbie = false
      @user_auth.save
      redirect_to welcome_path
    elsif session[:return_to]
      redirect_back
    else
      redirect_to questions_path
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

  private

  def create_or_find_user_by_omniauth
    @user_auth = UserAuth.from_omniauth(request.env['omniauth.auth'])

    # TODO: don't really care for this
    # prefer to replace # with longer UUID
    session[:user_auth_id] = @user_auth.id

    flash[:success] = 'Welcome, #{@user.name}!'
  rescue
    flash[:warning] = 'There was an error trying to authenticate you.'
  end
end
