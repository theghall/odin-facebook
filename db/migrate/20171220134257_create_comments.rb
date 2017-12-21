class CreateComments < ActiveRecord::Migration[5.1]
  def change
    create_table :comments do |t|
      t.references :post, foreign_key: true
      t.references :user, foreign_key: true
      t.text :content

      t.timestamps
    end
    add_index :comments, [:post_id, :user_id]
  end
end
