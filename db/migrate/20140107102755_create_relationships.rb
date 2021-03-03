class CreateRelationships < ActiveRecord::Migration[4.2]
  def change
    create_table :relationships do |t|
      t.integer :member_id
      t.integer :event_id
      t.boolean :presenter_flg, :default => false
      t.integer :status
      t.timestamps
    end
    add_index :relationships, :member_id
    add_index :relationships, :event_id
    add_index :relationships, [:member_id, :event_id], unique: true
    add_index :relationships, :presenter_flg
    add_index :relationships, :status

  end
end
