class RemoveCountryFromPartners < ActiveRecord::Migration
  def up
    remove_column :partners, :country
  end

  def down
    add_column :partners, :country, :string
  end
end
