# Question model mainly holds text and author of a question
# as well as various methods for collecting questions depending
# on a particular user's response to it
class Question < ApplicationRecord
  belongs_to :user_auth

  has_many :choices, inverse_of: :question, dependent: :destroy
  has_many :voices, dependent: :destroy

  is_blank_proc = proc { |attribs| attribs[:text].blank? }
  accepts_nested_attributes_for :choices, reject_if: is_blank_proc
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
    !arr.empty? && arr[0] == pass_choice_id
  end

  def self.get_unseen_for(some_user_auth)
    return nil unless some_user_auth
    return nil unless some_user_auth.id.is_a? Integer
    Question.joins("LEFT OUTER JOIN voices ON voices.question_id = questions.id
                   AND voices.user_auth_id = #{some_user_auth.id}")
            .includes(:choices)
            .where(voices: { id: nil })
            .order(cents: :desc)
  end

  def self.get_voiced_for(some_user_auth)
    return nil unless some_user_auth
    return nil unless some_user_auth.id.is_a? Integer
    # TODO: add is_passed to voices and join on is_passed: false
    Question.eager_load(:choices)
            .joins("JOIN voices ON voices.question_id = questions.id
                    AND voices.user_auth_id = #{some_user_auth.id}
                    AND voices.is_pass = false")
            .order(cents: :desc)
  end

  def self.get_passed_for(some_user_auth)
    return nil unless some_user_auth
    return nil unless some_user_auth.id.is_a? Integer
    # TODO: add is_passed and join on is_passed: true
    Question.eager_load(:choices)
            .joins("JOIN voices ON voices.question_id = questions.id
                    AND voices.user_auth_id = #{some_user_auth.id}
                    AND voices.is_pass = true")
            .order(cents: :desc)
  end
end
