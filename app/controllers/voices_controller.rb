# This is the controller for Voices
# Voices are a representation of a given user's action on
# a question, whether that is a choice or pass.
class VoicesController < ApplicationController
  before_action :set_voice, only: [:show]
  before_filter :require_logged_in

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

    return unless check_and_scrub_params these_params

    @voice = Voice.new(these_params)
    @voice.save # need to handle errors here better

    transact_cents

    set_js_instance_variables

    # procedure follows to views/voices/create.js.erb
  end

  private

  def award_cents_to_author_from_old(old_cents)
    return unless @question.cents / 100 > old_cents / 100
    # TODO: decide a good way to notify awarded authors of their
    # cents gained
    @question.user_auth.cents += 10
    @question.user_auth.save
  end

  def check_and_scrub_params(params)
    return false unless require_valid_params(params) && !noop_for_recreate

    @question = @choice.question

    # Before creating a voice, delete any existing voice(s) the user
    # might have for this question.
    old_voice_count = Voice.where(
      question_id: @question.id, user_auth_id: current_user_auth.id
    ).delete_all

    update_user_stars(@choice) if old_voice_count.zero?

    scrub_params params

    true
  end

  def donate_cents_to_question(n)
    @question.cents += n
    current_user_auth.cents -= n
    @question.save
    current_user_auth.save
  end

  def noop_for_recreate
    # instruct the browser to do nothing at all if the choice
    # already exists
    user_id = current_user_auth.id
    if Voice.exists?(user_auth_id: user_id, choice_id: @choice.id)
      head :ok, content_type: 'text/html'
      return true
    end
    false
  end

  def notice_insufficient_funds
    # end without action if not a pass and can't donate 2 cents
    poverty_notice = ' 2 ¢ is required to create a voice.'
    poverty = (current_user_auth.cents < 2 && !@choice_is_pass)
    notice_if poverty, poverty_notice
  end

  def require_valid_params(params)
    flash[:notice] = ''

    @choice = Choice.find(params['choice_id'])
    @choice_is_pass = @choice.ordinality.zero?

    # cannot proceed past this error because afterwards
    # we assume @choice is a valid object
    choice_invalid_notice = ' An invalid choice ID was sent.'
    return false if notice_if @choice.nil?, choice_invalid_notice

    return false if notice_insufficient_funds

    true
  end

  def set_js_instance_variables
    # these instance variables are needed for the JavaScript
    # which will replace the choices list clientside
    @panel_num_word = params['panel_num_word']
    @num_word = @panel_num_word
    @my_choice_ids = [@choice.id]
    # @my_choice_ids = [] if error_encountered
    @star_count = current_user_auth.star_count
  end

  # Use callbacks to share common setup or constraints between actions.
  def set_voice
    @voice = Voice.find(params[:id])
  end

  def scrub_params(params)
    params['question_id'] = @question.id
    params['user_auth_id'] = current_user_auth.id
    params['is_pass'] = @choice_is_pass
  end

  def transact_cents
    return if @choice_is_pass
    old_cents = @question.cents
    donate_cents_to_question 2
    award_cents_to_author_from_old old_cents
  end

  def update_user_stars(choice)
    # award a star if the new choice is the most popular, before
    # creating it.

    # TODO: do this on DB side by issuing one SELECT choice_id,
    # COUNT(voices) FROM choices JOIN voices ON
    # voices.choice_id = choices.id GROUP BY choice_id
    # -- if DB becomes large, will need to use caching instead

    max_voices = @question.choices.map(&:voices_count).max

    if choice.voices_count == max_voices
      current_user_auth.star_count += 1
    else
      current_user_auth.star_count = 0
    end
    current_user_auth.save
  end

  # Never trust parameters from the scary internet, only allow the
  # white list through.
  def voice_params
    params.require(:voice).permit(:choice_id)
  end
end
