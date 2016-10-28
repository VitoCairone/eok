class Voice < ApplicationRecord
  belongs_to :user_auth
  belongs_to :question
  belongs_to :choice

  scope :said_by_obj, -> (user_auth) { where(user_auth: user_auth.id) }
  scope :said_by_id, -> (id) { where(user_auth_id: id) }
end
