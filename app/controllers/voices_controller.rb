class VoicesController < ApplicationController
  before_action :set_voice, only: [:show]

  # GET /voices
  # GET /voices.json
  def index
    @voices = Voice.all
  end

  # GET /voices/1
  # GET /voices/1.json
  def show
  end

  # POST /voices
  # POST /voices.json
  def create
    these_params = voice_params
    error_encountered = false

    choice_id = these_params['choice_id']
    choice = Choice.find(choice_id)
    return if choice.nil?
    question_id = choice.question_id
    
    @choice_is_pass = (choice.ordinality == 0)

    return if current_user_auth.nil?

    # end without action if not a pass and can't donate 2 cents
    if (current_user_auth.cents < 2 and !@choice_is_pass)
      flash[:notice] = ' 2 ¢ is required to create a voice.'
      error_encountered = true
    end

    @question = Question.find(question_id)

    unless error_encountered

      user_auth_id = current_user_auth.id
      # end without action if the choice already exists
      if Voice.exists?(user_auth_id: user_auth_id, choice_id: choice_id)
        head :ok, content_type: "text/html"
        return
      end

      # Before creating a voice, delete any existing voice(s) the user
      # might have for this question.
      old_voice_count = Voice.where(question_id: question_id, user_auth_id: user_auth_id).delete_all

      # award a star if the new choice is the most popular, before
      # creating it.

      # TODO: do this on DB side by issuing one SELECT choice_id,
      # COUNT(voices) FROM choices JOIN voices ON
      # voices.choice_id = choices.id GROUP BY choice_id
      # -- if DB becomes large, will need to use caching instead
      max_voices = @question.choices.map{ |c| c.voices_count}.max

      if old_voice_count == 0 # alter stars only on first voicing
        if ((choice.voices_count + 1) >= max_voices)
          current_user_auth.star_count += 1
          current_user_auth.save
        else
          if current_user_auth.star_count != 0
            current_user_auth.star_count = 0
            current_user_auth.save
          end
        end
      end
      
      these_params = voice_params;
      these_params['question_id'] = question_id
      these_params['user_auth_id'] = user_auth_id
      these_params['is_pass'] = @choice_is_pass
      @voice = Voice.new(these_params)

      @voice.save # need to handle errors here better

      unless @choice_is_pass
        old_cents = @question.cents
        @question.cents += 2
        current_user_auth.cents -= 2
        @question.save
        current_user_auth.save
        if @question.cents / 100 > old_cents / 100
          # TODO: decide a good way to notify awarded authors of their
          # cents gained
          question.user_auth.cents += 10;
          question.user_auth.save
        end
      end

    end

    # these instance variables are needed for the JavaScript
    # which will replace the choices list clientside
    @panel_num_word = params['panel_num_word']
    @num_word = @panel_num_word
    @my_choice_ids = [choice.id]
    @my_choice_ids = [] if error_encountered
    @star_count = current_user_auth.star_count

    # procedure follows to views/voices/create.js.erb
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_voice
      @voice = Voice.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voice_params
      params.require(:voice).permit(:choice_id)
    end
end
