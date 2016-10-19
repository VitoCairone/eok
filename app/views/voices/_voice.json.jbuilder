json.extract! voice, :id, :user_auth_id, :question_id, :choice_id, :created_at, :updated_at
json.url voice_url(voice, format: :json)