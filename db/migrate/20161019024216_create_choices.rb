class CreateChoices < ActiveRecord::Migration[5.0]
  def change
    create_table :choices do |t|
      t.text :text
      t.references :question, foreign_key: true
      t.integer :ordinality
      t.integer :voice_count
      t.boolean :is_pass

      t.timestamps
    end
  end
end
