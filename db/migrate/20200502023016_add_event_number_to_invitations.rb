class AddEventNumberToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :event_number, :integer, :default => 0
  end
end
