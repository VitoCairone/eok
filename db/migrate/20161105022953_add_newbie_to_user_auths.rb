class AddNewbieToUserAuths < ActiveRecord::Migration[5.0]
  def change
    add_column :user_auths, :newbie, :boolean, default: true
  end
end
