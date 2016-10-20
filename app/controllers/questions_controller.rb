class QuestionsController < ApplicationController
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /questions
  # GET /questions.json
  def index
    # @ questions = Questions.get_unseen_for(current_user_auth, 5)
    @questions = Question.all.order(cents: :desc).limit(5)
  end

  # GET /questions/1
  # GET /questions/1.json
  def show
  end

  # GET /questions/new
  def new
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
      idx += 1;
    end

    # this is where :acceps_nested_attributes_for
    # creates all the associated choices also
    @question = Question.new(these_params)
    @question.user_auth = current_user_auth
    @question.cents = 5

    # TODO: add Pass as a choice with ordinality 0
    # @question.choices.build{text: "Pass", is_pass: true, ordinality: 0}

    respond_to do |format|
      if @question.save
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
      puts "!!!!!"
      safe_params = params.require(:question).permit(:text, :anonymous, :randomize, choices_attributes: [:id, :text])
      # safe_params['cents'] = 5; # TODO: move to a config somewhere
      # safe_params['user_auth_id'] = current_user_auth.id || nil
      # puts "@@@"
      # puts safe_params.inspect
      # puts "~~~~~~"
      safe_params
    end
end
