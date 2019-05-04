class AddPreviousAffiliationToMembers < ActiveRecord::Migration
  def change
    add_column :members, :previous_affiliation, :string
  end
end
