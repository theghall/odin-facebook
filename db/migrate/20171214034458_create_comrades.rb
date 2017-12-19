class CreateComrades < ActiveRecord::Migration[5.1]
  def change
    create_table :comrades do |t|
      t.integer :requestor_id
      t.integer :requestee_id
      t.boolean :accepted

      t.timestamps
    end
    add_index :comrades, :requestor_id
    add_index :comrades, :requestee_id
    add_index :comrades, [:requestor_id, :requestee_id], unique: true
  end
end
