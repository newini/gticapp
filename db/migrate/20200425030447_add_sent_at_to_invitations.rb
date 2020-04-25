class AddSentAtToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :sent_at, :datatime
  end
end
