class AddIncludeAllFlgToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :include_all_flg, :boolean, :default => false
  end
end
