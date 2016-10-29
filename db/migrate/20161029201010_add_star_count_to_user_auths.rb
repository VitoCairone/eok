class AddStarCountToUserAuths < ActiveRecord::Migration[5.0]
  def change
    add_column :user_auths, :star_count, :integer
  end
end
