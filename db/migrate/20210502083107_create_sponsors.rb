class CreateSponsors < ActiveRecord::Migration[6.1]
  def change
    create_table :sponsors do |t|
      t.string :name
      t.binary :logo_data
      t.string :logo_name
      t.string :logo_mime_type
      t.string :slogan
      t.string :description
      t.string :website
      t.string :note
      t.boolean :is_end

      t.timestamps
    end
  end
end
