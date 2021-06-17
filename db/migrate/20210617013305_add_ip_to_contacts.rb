class AddIpToContacts < ActiveRecord::Migration[6.1]
  def change
    add_column :contacts, :ip, :string
  end
end
