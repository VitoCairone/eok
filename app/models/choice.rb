class Choice < ApplicationRecord
  belongs_to :question

  has_many :voices, dependent: :destroy
end