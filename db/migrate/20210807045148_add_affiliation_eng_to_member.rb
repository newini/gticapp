class AddAffiliationEngToMember < ActiveRecord::Migration[6.1]
  def change
    add_column :members, :affiliation_eng, :string
  end
end
