class ChangeIncludeGticFlgToInvitations < ActiveRecord::Migration[4.2]
  def change
    change_column :invitations, :include_gtic_flg, :boolean, :default => false
  end
end
