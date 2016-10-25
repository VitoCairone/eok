class VoicesController < ApplicationController
  before_action :set_voice, only: [:show, :edit, :update, :destroy]

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
    Voice.delete_all(question_id: question_id, user_auth_id: user_auth_id)
    
    these_params = voice_params;
    these_params['question_id'] = question_id
    these_params['user_auth_id'] = user_auth_id
    @voice = Voice.new(these_params)

    respond_to do |format|
      if @voice.save
        # TODO: redirecting to questions index is a bad hack;
        # this causes us to lose our current expanded question and go back
        # to a collapsed carousel. Need to try to handle voice creation
        # entirely by AJAX without a page load.
        format.html { redirect_to :questions, notice: 'Voice was successfully created.' }
        format.json { render :show, status: :created, location: @voice }
      else
        format.html { render :new }
        format.json { render json: @voice.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /voices/1
  # PATCH/PUT /voices/1.json
  def update
    respond_to do |format|
      if @voice.update(voice_params)
        format.html { redirect_to @voice, notice: 'Voice was successfully updated.' }
        format.json { render :show, status: :ok, location: @voice }
      else
        format.html { render :edit }
        format.json { render json: @voice.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /voices/1
  # DELETE /voices/1.json
  def destroy
    @voice.destroy
    respond_to do |format|
      format.html { redirect_to voices_url, notice: 'Voice was successfully destroyed.' }
      format.json { head :no_content }
    end
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
