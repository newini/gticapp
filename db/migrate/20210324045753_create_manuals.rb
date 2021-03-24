class CreateManuals < ActiveRecord::Migration[6.1]
  def change
    create_table :manuals do |t|
      t.string :title
      t.text :body

      t.timestamps
    end
  end
end
