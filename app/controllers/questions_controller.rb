class QuestionsController < ApplicationController
  before_filter :store_return_to
  before_filter :require_logged_in
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /questions
  def index
    @this_page = 'Home'
    # puts "in index method"
    fetch_page = params[:page] or 1
    @questions = Question.get_unseen_for(current_user_auth).paginate(page: fetch_page, per_page: 5)
    # @questions = Question.includes(:choices).order(cents: :desc).limit(5)
    # puts "index first step complete"
    
    @my_voices = Voice.where(user_auth_id: current_user_auth.id)
    # @my_voices = []
  end

  # GET /questions/voiced
  def voiced
    @this_page = 'Voiced'
    #@questions = Question.get_voiced_for(current_user_auth)
    fetch_page = params[:page] or 1
    @questions = Question.get_voiced_for(current_user_auth).paginate(page: fetch_page, per_page: 5)
    # From this join we already know all the user's voices,
    # but we awkwardly compute them again many times.
    # TODO: refactor this to use existing data better
    @my_voices = Voice.where(user_auth_id: current_user_auth.id)
    # @my_voices = Voice.joins(:choices)
    #   .where(user_auth_id: current_user_auth.id)
    #   .where.not(choices: {ordinality: 0})

    render :voiced
  end

  # GET /questions/passed
  def passed
    @this_page = 'Passed'
    fetch_page = params[:page] or 1
    @questions = Question.get_passed_for(current_user_auth).paginate(page: fetch_page, per_page: 5)
    @my_voices = Voice.where(user_auth_id: current_user_auth.id)
    # @my_voices = Voice.joins(:choices).where(
    #   user_auth_id: current_user_auth.id,
    #   choices: {ordinality: 0 }
    # )

    render :passed
  end

  # GET /questions/1
  def show
  end

  # GET /questions/new
  def new
    @this_page = 'Write'
    # Create a new blank question so we can reuse
    # view logic for 'new' and 'edit'. This doesn't
    # hit the database until 'create'.
    @question = Question.new
    7.times { @question.choices.build }
  end

  # GET /questions/1/edit
  def edit
  end

  # POST /questions
  # POST /questions.json
  def create
    these_params = question_params
    choices_attribs = these_params['choices_attributes']

    # drop all blank choices
    choices_attribs.keep_if { |k, v| !v['text'].blank? }

    # assign ordinality, ensuring a consecutively numbered
    # set of non-blank choices are always sent to the database.
    idx = 1;
    choices_attribs.each do |k, v|
      v['ordinality'] = idx;
      v['is_pass'] = false;
      idx += 1;
    end

    # this is where :acceps_nested_attributes_for
    # creates all the associated choices also
    @question = Question.new(these_params)
    @question.user_auth = current_user_auth
    @question.cents = 5

    respond_to do |format|
      if @question.save

        # with the question saved, add one more choice which is the pass.
        # prefer to create this along with other choices if possible,
        # without opening integrity vulnerabilities to bad requests.
        @question.choices.build(text: 'pass', ordinality: 0, is_pass: true)
        @question.save

        format.html { redirect_to @question, notice: 'Question was successfully created.' }
        format.json { render :show, status: :created, location: @question }
      else
        format.html { render :new }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /questions/1
  # PATCH/PUT /questions/1.json
  def update
    respond_to do |format|
      if @question.update(question_params)
        format.html { redirect_to @question, notice: 'Question was successfully updated.' }
        format.json { render :show, status: :ok, location: @question }
      else
        format.html { render :edit }
        format.json { render json: @question.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /questions/1
  # DELETE /questions/1.json
  def destroy
    @question.destroy
    respond_to do |format|
      format.html { redirect_to questions_url, notice: 'Question was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_question
      @question = Question.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def question_params
      safe_params = params.require(:question).permit(:text, :anonymous, :randomize, choices_attributes: [:id, :text])
      safe_params
    end

    def store_return_to
      session[:return_to] = request.url
    end

    # Can't interact without a login
    def require_logged_in
      redirect_to login_path unless current_user_auth
    end
end
