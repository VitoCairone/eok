# The Choice model just holds the text of a choice,
# and a link to its question
class Choice < ApplicationRecord
  belongs_to :question

  has_many :voices, dependent: :destroy

  def voices_count
    voices.count
  end
end
