class ChangeEventIdToInvitations < ActiveRecord::Migration
  def change
    change_column :invitations, :event_id, :integer, :default => 0
  end
end
