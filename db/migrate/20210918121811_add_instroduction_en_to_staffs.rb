class AddInstroductionEnToStaffs < ActiveRecord::Migration[6.1]
  def change
    rename_column :staffs, :description, :introduction_jp
    add_column :staffs, :introduction_en, :string
  end
end
