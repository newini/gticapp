class AddSentToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :sent_flg, :boolean
  end
end
