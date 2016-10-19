json.extract! question, :id, :text, :user_auth_id, :anonymous, :cents, :randomize, :created_at, :updated_at
json.url question_url(question, format: :json)