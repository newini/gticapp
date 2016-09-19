class CreateMemberRelationships < ActiveRecord::Migration
  def change
    create_table :member_relationships do |t|
      t.integer :introduced_id
      t.integer :introducer_id

      t.timestamps
    end
    add_index :member_relationships, :introduced_id
    add_index :member_relationships, :introducer_id
    add_index :member_relationships, [:introduced_id, :introducer_id], unique: true
  end
end
