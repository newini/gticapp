class RemoveGreetingFromInvitations < ActiveRecord::Migration
  def change
    remove_column :invitations, :greeting, :text
  end
end
