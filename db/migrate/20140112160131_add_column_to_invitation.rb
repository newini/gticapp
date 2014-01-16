class AddColumnToInvitation < ActiveRecord::Migration
  def change
    add_column :invitations, :greeting, :text
  end
end
