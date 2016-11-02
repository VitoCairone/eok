class SetCentsDefaultOnQuestions < ActiveRecord::Migration[5.0]
  def up
    change_column :questions, :cents, :integer, default: 5
  end

  def down
  end
end
