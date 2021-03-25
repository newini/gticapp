class CreateAttachmentFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :attachment_files do |t|
      t.binary :data
      t.string :filename, null: false, index: { unique: true  }
      t.string :mime_type

      t.timestamps
    end
  end
end
