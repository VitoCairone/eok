class CreateVoices < ActiveRecord::Migration[5.0]
  def change
    create_table :voices do |t|
      t.references :user_auth, foreign_key: true
      t.references :question, foreign_key: true
      t.references :choice, foreign_key: true

      t.timestamps
    end
  end
end
