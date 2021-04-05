class RenameColumnInBroadcastMember < ActiveRecord::Migration[6.1]
  def change
    rename_column :broadcast_members, :invitation_id, :broadcast_id
  end
end
