# Don't worry, this can't really control your thoughts
class ThoughtsController < ApplicationController
  def new
    # use this .includes() to prevent n+1 queries when
    # we display the thought owners' names and/or pics
    @thoughts = Thought.all.includes(:user_auth)
  end

  def create
    return unless enforce_logged_in

    these_params = thought_params
    @thought = Thought.find_or_create_by(
      user_auth_id: these_params['user_auth_id']
    )
    @thought.text = these_params['text']
    @thought.save
    redirect_to new_thought_path
  end

  private

  def thought_params
    safe_params = params.require(:thought).permit(:text)
    safe_params['user_auth_id'] = current_user_auth.id
    safe_params
  end

  def enforced_logged_in
    unless current_user_auth
      flash[:warning] = 'Must be logged in to post a thought.'
      redirect_to new_thought_path
      return false
    end
    true
  end
end
