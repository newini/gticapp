class RenameInvitationsToBroadcasts < ActiveRecord::Migration[6.1]
  def change
    rename_table :invitations, :broadcasts
  end
end
