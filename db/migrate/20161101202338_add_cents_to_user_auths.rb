class AddCentsToUserAuths < ActiveRecord::Migration[5.0]
  def change
    add_column :user_auths, :cents, :integer
  end
end
