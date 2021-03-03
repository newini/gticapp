class DeletePreviousAffiliationFromMembers < ActiveRecord::Migration[4.2]
  def change
    remove_column :members, :previous_affiliation, :string
  end
end
