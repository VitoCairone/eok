class AddUserAuthToThoughts < ActiveRecord::Migration[5.0]
  def change
    add_reference :thoughts, :user_auth, foreign_key: true
  end
end
