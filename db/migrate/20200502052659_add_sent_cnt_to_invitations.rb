class AddSentCntToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :sent_cnt, :integer
  end
end
