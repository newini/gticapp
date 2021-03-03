class RemoveGreetingFromInvitations < ActiveRecord::Migration[4.2]
  def change
    remove_column :invitations, :greeting, :text
  end
end
