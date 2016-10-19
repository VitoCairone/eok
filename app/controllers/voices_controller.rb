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

  # GET /voices/new
  def new
    @voice = Voice.new
  end

  # GET /voices/1/edit
  def edit
  end

  # POST /voices
  # POST /voices.json
  def create
    @voice = Voice.new(voice_params)

    respond_to do |format|
      if @voice.save
        format.html { redirect_to @voice, notice: 'Voice was successfully created.' }
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
      params.require(:voice).permit(:user_auth_id, :question_id, :choice_id)
    end
end
