class AddContributorFlgToMembers < ActiveRecord::Migration[4.2]
  def change
    add_column :members, :contributor_flg, :boolean, :default => false
  end
end
