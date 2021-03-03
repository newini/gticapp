class CreateRegisters < ActiveRecord::Migration[4.2]
  def change
    create_table :registers do |t|
      t.integer :event_id
      t.integer :account_id
      t.float :amount

      t.timestamps
    end
    add_index :registers, :event_id
    add_index :registers, :account_id
    add_index :registers, :amount
  end
end
