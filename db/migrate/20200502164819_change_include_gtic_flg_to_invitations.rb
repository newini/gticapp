class ChangeIncludeGticFlgToInvitations < ActiveRecord::Migration
  def change
    change_column :invitations, :include_gtic_flg, :boolean, :default => false
  end
end
