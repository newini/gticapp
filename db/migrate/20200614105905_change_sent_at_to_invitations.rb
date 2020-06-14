class ChangeSentAtToInvitations < ActiveRecord::Migration
  def change
    change_column :invitations, :sent_at, :datetime
  end
end
