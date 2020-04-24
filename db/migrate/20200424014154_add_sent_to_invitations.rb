class AddSentToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :sent_flg, :boolean
  end
end
