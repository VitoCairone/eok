class CreateQuestions < ActiveRecord::Migration[5.0]
  def change
    create_table :questions do |t|
      t.text :text
      t.references :user_auth, foreign_key: true
      t.boolean :anonymous
      t.integer :cents
      t.boolean :randomize

      t.timestamps
    end
  end
end
