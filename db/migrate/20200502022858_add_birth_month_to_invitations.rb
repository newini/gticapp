class AddBirthMonthToInvitations < ActiveRecord::Migration
  def change
    add_column :invitations, :birth_month, :integer, :default => 0
  end
end
