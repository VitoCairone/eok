class AddIsPassToVoices < ActiveRecord::Migration[5.0]
  def change
    add_column :voices, :is_pass, :boolean
  end
end
