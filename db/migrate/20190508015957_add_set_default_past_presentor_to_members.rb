class AddSetDefaultPastPresentorToMembers < ActiveRecord::Migration[4.2]
  def change
    change_column :members, :past_presenter_flg, :boolean, :default => false
  end
end
