class DropManual < ActiveRecord::Migration[6.1]
  def change
    drop_table :manuals
  end
end
