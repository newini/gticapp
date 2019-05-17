class AddContributorFlgToMembers < ActiveRecord::Migration
  def change
    add_column :members, :contributor_flg, :boolean, :default => false
  end
end
