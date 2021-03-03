class AddBirthMonthToInvitations < ActiveRecord::Migration[4.2]
  def change
    add_column :invitations, :birth_month, :integer, :default => 0
  end
end
