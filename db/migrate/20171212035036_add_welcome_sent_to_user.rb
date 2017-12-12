class AddWelcomeSentToUser < ActiveRecord::Migration[5.1]
  def change
    add_column :users, :welcome_sent, :boolean
  end
end
