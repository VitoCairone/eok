class UserAuth < ApplicationRecord
  has_one :thought

  class << self
    def from_omniauth(auth_hash)
      user_auth = find_or_create_by(uid: auth_hash['uid'], provider: auth_hash['provider'])
      user_auth.name = auth_hash['info']['name']
      user_auth.location = auth_hash['info']['location']
      user_auth.image_url = auth_hash['info']['image']
      user_auth.url = auth_hash['info']['urls'][user_auth.provider.capitalize]
      user_auth.save!
      user_auth
    end
  end
end
