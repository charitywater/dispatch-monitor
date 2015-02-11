class DropDailyLogs < ActiveRecord::Migration
  def up
    drop_table :daily_logs
  end

  def down
    create_table "daily_logs", force: true do |t|
      t.integer  "week",       null: false
      t.integer  "liters",     null: false, array: true
      t.json     "extra_data", null: false
      t.integer  "sensor_id",  null: false
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "daily_logs", ["sensor_id"], name: "index_daily_logs_on_sensor_id", using: :btree
  end
end
