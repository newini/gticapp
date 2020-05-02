class RemoveEventNumberFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :event_number, :integer
  end
end
