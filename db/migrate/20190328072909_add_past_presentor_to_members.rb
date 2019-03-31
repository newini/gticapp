class AddPastPresentorToMembers < ActiveRecord::Migration
  def change
    add_column :members, :past_presenter_flg, :boolean, after: :gtic_flg
  end
end
