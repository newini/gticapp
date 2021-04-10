class ChangesOnMembers < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :biography, :string
    add_column :members, :website, :string
    add_column :members, :country_code, :string, default: 'JP'
  end
end
