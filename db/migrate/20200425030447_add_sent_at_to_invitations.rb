class AddSentAtToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :sent_at, :datatime
  end
end
