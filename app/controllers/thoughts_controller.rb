class ThoughtsController < ApplicationController
  def new
    @thoughts = Thought.all
  end

  def create
    @thought = Thought.new(thought_params)

    @thought.save
    redirect_to new_thought_path
  end

  private
    def thought_params
      params.require(:thought).permit(:text)
    end
end
