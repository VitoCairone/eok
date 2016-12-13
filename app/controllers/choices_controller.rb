# controller for Choices;
# Choices are entities under questions, with associated text,
# for which Voices can be tabulated.
class ChoicesController < ApplicationController
  before_action :set_choice, only: [:show, :edit, :update, :destroy]

  # GET /choices
  # GET /choices.json
  def index
    @choices = Choice.all
  end

  # GET /choices/1
  # GET /choices/1.json
  def show
  end

  private

  def set_choice
    @choice = Choice.find(params[:id])
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def choice_params
    params.require(:choice).permit(
      :text, :question_id, :ordinality, :voice_count, :is_pass
    )
  end
end
