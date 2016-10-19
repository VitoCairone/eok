class Voice < ApplicationRecord
  belongs_to :user_auth
  belongs_to :question
  belongs_to :choice
end
