class AddEventNumberToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :event_number, :integer, :default => 0
  end
end
