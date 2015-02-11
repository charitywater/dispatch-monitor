class AddNameIndexToPartners < ActiveRecord::Migration
  def change
    add_index :partners, :name, unique: true
  end
end
