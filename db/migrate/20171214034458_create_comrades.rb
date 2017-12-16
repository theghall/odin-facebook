class CreateComrades < ActiveRecord::Migration[5.1]
  def change
    create_table :comrades do |t|
      t.integer :follower_id
      t.integer :followed_id
      t.boolean :accepted

      t.timestamps
    end
    add_index :comrades, :follower_id
    add_index :comrades, :followed_id
    add_index :comrades, [:follower_id, :followed_id], unique: true
  end
end
