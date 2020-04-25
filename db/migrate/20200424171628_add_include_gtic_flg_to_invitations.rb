class AddIncludeGticFlgToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :include_gtic_flg, :boolean, :default => true
  end
end
