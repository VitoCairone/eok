class VoicesController < ApplicationController

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

    choice = Choice.find(these_params['choice_id'])
    return if choice.nil?
    question_id = choice.question_id
    # puts "@@@@[A] " + question_id.to_s

    return if current_user_auth.nil?
    user_auth_id = current_user_auth.id
    # puts "@@@@[B]" + user_auth_id.to_s

    # Before creating a voice, delete any existing voice(s) the user
    # might have for this question.
    Voice.where(question_id: question_id, user_auth_id: user_auth_id).delete_all

    # award a star if the new choice is the most popular, before
    # creating it.

    # TODO: do this on DB side by issuing one SELECT choice_id,
    # COUNT(voices) FROM choices JOIN voices ON
    # voices.choice_id = choices.id GROUP BY choice_id
    # -- if DB becomes large, will need to use caching instead
    max_voices = Question.find(question_id)
                 .choices
                 .map{ |c| c.voices_count}
                 .max

    # puts "@@@@"
    # puts Question.find(question_id)
    # puts Question.find(question_id).choices.map{ |c| c.voices_count}
    # puts Question.find(question_id).choices.map{ |c| c.voices_count}.max    

    if (choice.voices_count >= max_voices)
      current_user_auth.star_count = 0 unless current_user_auth.star_count      
      current_user_auth.star_count += 1
      # puts "STARS set to"
      # puts current_user_auth.star_count
      current_user_auth.save
    else
      if current_user_auth.star_count != 0
        current_user_auth.star_count = 0
        # puts "STARS set to"
        # puts current_user_auth.star_count
        current_user_auth.save
      end
    end
    
    these_params = voice_params;
    these_params['question_id'] = question_id
    these_params['user_auth_id'] = user_auth_id
    @choice_is_pass = (choice.ordinality == 0)
    these_params['is_pass'] = @choice_is_pass
    @voice = Voice.new(these_params)

    @voice.save # need to handle errors here better

    # these instance variables are needed for the JavaScript
    # which will replace the choices list clientside
    @panel_num_word = params['panel_num_word']
    @question = Question.find(question_id)
    @num_word = @panel_num_word
    @my_choice_ids = [choice.id]
    @star_count = current_user_auth.star_count

    # procedure follows to views/voices/create.js.erb
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_voice
    #   @voice = Voice.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def voice_params
      params.require(:voice).permit(:choice_id)
    end
end
