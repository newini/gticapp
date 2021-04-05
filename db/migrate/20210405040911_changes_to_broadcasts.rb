class ChangesToBroadcasts < ActiveRecord::Migration[6.1]
  def up
    change_column :broadcasts, :sent_flg, :boolean, default: false

    rename_column :broadcasts, :title, :subject
    rename_column :broadcasts, :content, :body
  end

  def down
    change_column :broadcasts, :sent_flg, :boolean
  end
end
