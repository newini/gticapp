class AddSetDefaultPastPresentorToMembers < ActiveRecord::Migration
  def change
    change_column :members, :past_presenter_flg, :boolean, :default => false
  end
end
