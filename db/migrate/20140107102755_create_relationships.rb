class CreateRelationships < ActiveRecord::Migration
  def change
    create_table :relationships do |t|
      t.integer :participated_id
      t.integer :participant_id

      t.timestamps
    end
    add_index :relationships, :participated_id
    add_index :relationships, :participant_id
    add_index :relationships, [:participated_id, :participant_id], unique: true
  end
end
