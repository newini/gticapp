class CreateMemberInvitationRelationships < ActiveRecord::Migration
  def change
    create_table :member_invitation_relationships do |t|
      t.integer :member_id
      t.integer :invitation_id
      t.boolean :sent_flg, :default => false

      t.timestamps null: false
    end
  end
end
