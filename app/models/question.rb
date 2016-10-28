class Question < ApplicationRecord
  belongs_to :user_auth

  has_many :choices, inverse_of: :question, dependent: :destroy
  has_many :voices, dependent: :destroy

  accepts_nested_attributes_for :choices, reject_if: proc { |attribs| attribs[:text].blank? }
  # since the UI for choice create/edit dictates
  # to specify a blank, there is no need to accept
  # direct destroy requests

  def author
    user_auth.name
  end

  def pass_choice_id
    # TODO: seems like a better idea to just track this as 
    # a field on the question
    choices.where(ordinality: 0).first.id
  end

  def test_is_pass(arr)
    arr.length > 0 and arr[0] == pass_choice_id
  end

  def self.get_unseen_for(some_user_auth, limit=100)
    # simple:
    # Question.includes(:choices).order(cents: :desc).limit(5)
    return nil unless some_user_auth
    return nil unless some_user_auth.id.is_a? Integer
    Question.joins("LEFT OUTER JOIN voices ON voices.question_id = questions.id
                   AND voices.user_auth_id = #{some_user_auth.id}")
            .includes(:choices)
            .where(voices: {id: nil})
            .order(cents: :desc).limit(limit)
  end

end
