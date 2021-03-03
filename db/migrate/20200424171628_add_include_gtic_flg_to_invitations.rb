class AddIncludeGticFlgToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :include_gtic_flg, :boolean, :default => true
  end
end
