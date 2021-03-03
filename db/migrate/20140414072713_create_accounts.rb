class CreateAccounts < ActiveRecord::Migration[4.2]
  def change
    create_table :accounts do |t|
      t.string :title
      t.float :amount
      t.integer :event_id
      t.boolean :positive

      t.timestamps
    end
    add_index :accounts, :title
    add_index :accounts, :amount
    add_index :accounts, :event_id
    add_index :accounts, :positive
  end
end
