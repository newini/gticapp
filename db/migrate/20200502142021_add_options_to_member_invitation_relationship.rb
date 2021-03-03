class AddOptionsToMemberInvitationRelationship < ActiveRecord::Migration[4.2]
  def change
    add_column :member_invitation_relationships, :include_all_flg, :boolean, :default => false
    add_column :member_invitation_relationships, :include_gtic_flg, :boolean, :default => false
    add_column :member_invitation_relationships, :birth_month, :integer, :default => 0
    add_column :member_invitation_relationships, :event_id, :integer, :default => 0
  end
end
