class CreateGpsMessage < ActiveRecord::Migration
  def change
    create_table :gps_messages do |t|
      t.string :esn
      t.datetime :transmitted_at
      t.string :payload
      t.timestamps
    end
  end
end
