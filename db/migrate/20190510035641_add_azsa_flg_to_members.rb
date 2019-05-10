class AddAzsaFlgToMembers < ActiveRecord::Migration
  def change
    add_column :members, :azsa_flg, :boolean, :default => false
  end
end
