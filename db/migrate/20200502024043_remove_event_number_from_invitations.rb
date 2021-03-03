class RemoveEventNumberFromInvitations < ActiveRecord::Migration[4.2]
  def change
    remove_column :invitations, :event_number, :integer
  end
end
