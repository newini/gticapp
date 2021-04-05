class RenameMemberInvitationRelaTableToBroadcastMember < ActiveRecord::Migration[6.1]
  def change
    rename_table :member_invitation_relationships, :broadcast_members
  end
end
