class AddSentCntToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :sent_cnt, :integer
  end
end
