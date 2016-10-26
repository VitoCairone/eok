class Choice < ApplicationRecord
  belongs_to :question

  has_many :voices, dependent: :destroy

  def voices_count
    voices.count
  end
end