class SetDefaultsOnUserAuths < ActiveRecord::Migration[5.0]
  def up
    change_column :user_auths, :star_count, :integer, default: 0
    change_column :user_auths, :cents, :integer, default: 350
  end

  def down
  end
end
