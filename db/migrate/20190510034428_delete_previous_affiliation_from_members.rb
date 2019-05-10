class DeletePreviousAffiliationFromMembers < ActiveRecord::Migration
  def change
    remove_column :members, :previous_affiliation, :string
  end
end
