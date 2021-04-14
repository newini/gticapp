class RenameAttachmentFilesToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :attachment_files, :tags, :string

    rename_table :attachment_files, :images
  end
end
