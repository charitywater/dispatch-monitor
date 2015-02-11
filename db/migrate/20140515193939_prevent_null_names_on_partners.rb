class PreventNullNamesOnPartners < ActiveRecord::Migration
  def change
    change_column :partners, :name, :string, null: false
  end
end
