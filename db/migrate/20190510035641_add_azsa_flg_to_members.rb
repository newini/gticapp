class AddAzsaFlgToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :azsa_flg, :boolean, :default => false
  end
end
