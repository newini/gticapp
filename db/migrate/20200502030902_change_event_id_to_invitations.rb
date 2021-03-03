class ChangeEventIdToInvitations < ActiveRecord::Migration[4.2]
  def change
    change_column :invitations, :event_id, :integer, :default => 0
  end
end
