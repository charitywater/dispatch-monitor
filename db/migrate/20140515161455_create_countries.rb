class CreateCountries < ActiveRecord::Migration
  def change
    create_table :countries do |t|
      t.string :name, null: false
      t.index :name, unique: true
      t.timestamps
    end
  end
end
