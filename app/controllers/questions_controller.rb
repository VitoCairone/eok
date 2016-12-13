# Controller for Questions routes.
# Questions has standard CRUD methods
# as well as /voiced and /passed variants on /index,
# which are divided up by whether the user has responded and how.
# /index shows questions the user hasn't responded
# /voiced shows questions the user created a (non-pass) voice
# /passed shows questions the user passed on
# may consider hiding or decreasing in prominence /passed view
#
# TODO: implemented Edit interface
class QuestionsController < ApplicationController
  before_filter :store_return_to
  before_filter :require_logged_in
  before_action :set_question, only: [:show, :edit, :update, :destroy]

  # GET /questions
  def index
    @this_page = 'Home'
    fetch_page = params[:page] || 1
    @questions = Question.get_unseen_for(current_user_auth)
                         .paginate(page: fetch_page, per_page: 5)

    @my_voices = Voice.where(user_auth_id: current_user_auth.id)

    @n_unresponded = @questions.count
    # why is this not 5 when returned from a paginated request ??
    @n_unresponded = 5 if @n_unresponded > 5
  end

  # GET /questions/voiced
  def voiced
    @this_page = 'Voiced'
    fetch_page = params[:page] || 1
    @questions = Question.get_voiced_for(current_user_auth)
                         .paginate(page: fetch_page, per_page: 5)

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
    fetch_page = params[:page] || 1
    @questions = Question.get_passed_for(current_user_auth)
                         .paginate(page: fetch_page, per_page: 5)
    @my_voices = Voice.where(user_auth_id: current_user_auth.id)
    # @my_voices = Voice.joins(:choices).where(
    #   user_auth_id: current_user_auth.id,
    #   choices: {ordinality: 0 }
    # )

    render :passed
  end

  # GET /questions/1
  def show
    @my_voices = Voice.where(user_auth_id: current_user_auth.id)
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

    # check params, updating notice with all errors found,
    # returning true (thus preventing exit from this fn) only on success
    return unless require_valid_params these_params

    @question = make_question these_params

    respond_to do |format|
      if @question.save
        # here we somewhat awkwardly always save twice, but it seems only
        # right that cents are not transacted until the question is created
        # and saved successfully
        donate_user_cents_to_question 5

        created_notice = 'Question was successfully created.'
        format.html { redirect_to @question, notice: created_notice }
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
        updated_notice = 'Question was successfully updated.'
        format.html { redirect_to @question, notice: updated_notice }
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
    destroyed_notice = 'Question was successfully destroyed.'
    respond_to do |format|
      format.html { redirect_to questions_url, notice: destroyed_notice }
      format.json { head :no_content }
    end
  end

  private

  def donate_user_cents_to_question(n)
    current_user_auth.cents -= n
    current_user_auth.save

    @question.cents += n
    @question.save
  end

  def make_question(params)
    # this is where :acceps_nested_attributes_for
    # creates all the associated choices also
    question = Question.new(params)

    # ignore any user specified by the request and always use the
    # session-based notion of the current user
    question.user_auth = current_user_auth

    # Add one more choice which is the pass.
    # prefer to create this along with other choices if possible.
    question.choices.build(text: 'pass', ordinality: 0, is_pass: true)

    question
  end

  def notice_if(condition, notice)
    if condition
      flash[:notice] += notice
      return true
    end
    false
  end

  # Never trust parameters from the scary internet,
  # only allow the white list through.
  def question_params
    # TODO: check how many times this is called; some of this syntax
    # here or with these_params = question_params may be unnecessary
    safe_params = params.require(:question).permit(
      :text, :anonymous, :randomize, choices_attributes: [:id, :text]
    )
    safe_params
  end

  # Can't interact without a login
  def require_logged_in
    redirect_to login_path unless current_user_auth
  end

  def require_valid_params(params)
    flash[:notice] = ''
    error_encountered = false

    notice_blank = ' Question text cannot be blank.'
    error_encountered |= notice_if params['text'].blank?, notice_blank

    # drop all blank choices and
    # assign ordinality, ensuring a consecutively numbered
    # set of non-blank choices are always sent to the database.
    scrub_choices_attributes params['choices_attributes']

    # reject questions with less than 3 non-blank answers
    choice_count = params['choices_attributes'].count
    notice_few_choices = ' At least 3 answers are required.'
    error_encountered |= notice_if (choice_count < 3), notice_few_choices

    if error_encountered
      @question = Question.new(params)
      # create blank choices enough to make 7 so the re-rendered
      # new view will properly display
      (7 - @question.choices.size).times { @question.choices.build }
      render :new
      return false
    end

    true
  end

  def scrub_choices_attributes(choices_attribs)
    choices_attribs.keep_if { |_k, v| !v['text'].blank? }
    idx = 1
    choices_attribs.each do |_k, v|
      v['ordinality'] = idx
      v['is_pass'] = false
      idx += 1
    end
  end

  def set_question
    @question = Question.find(params[:id])
  end

  def store_return_to
    session[:return_to] = request.url
  end
end
