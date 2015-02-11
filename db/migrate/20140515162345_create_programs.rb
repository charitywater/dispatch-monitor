class CreatePrograms < ActiveRecord::Migration
  def change
    create_table :programs do |t|
      t.belongs_to :country, index: true, null: false
      t.belongs_to :partner, index: true, null: false
      t.index [:partner_id, :country_id], unique: true
      t.timestamps
    end
  end
end
