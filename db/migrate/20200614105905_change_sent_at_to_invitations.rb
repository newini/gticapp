class ChangeSentAtToInvitations < ActiveRecord::Migration[4.2]
  def change
    change_column :invitations, :sent_at, :datetime
  end
end
