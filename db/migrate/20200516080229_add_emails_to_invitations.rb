class AddEmailsToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :emails, :string
  end
end
