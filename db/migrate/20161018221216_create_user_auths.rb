class CreateUserAuths < ActiveRecord::Migration[5.0]
  def change
    create_table :user_auths do |t|
      t.string :provider, null: false
      t.string :uid, null: false
      t.string :name
      t.string :location
      t.string :image_url
      t.string :url

      t.timestamps
    end

    add_index :user_auths, :provider
    add_index :user_auths, :uid
    add_index :user_auths, [:provider, :uid], unique: true
  end
end
