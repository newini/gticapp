class CreateContacts < ActiveRecord::Migration[6.1]
  def change
    create_table :contacts do |t|
      t.string :name
      t.integer :category_id
      t.string :affiliation
      t.string :title
      t.string :email
      t.string :subject
      t.text :body

      t.boolean :is_read, default: false
      t.boolean :is_response_completed, default: false

      t.timestamps
    end
  end
end
