class CreateDailyLogs < ActiveRecord::Migration
  def change
    create_table :daily_logs do |t|
      t.integer :week, null: false
      t.integer :liters, array: true, null: false
      t.json :extra_data, null: false
      t.belongs_to :sensor, index: true, null: false

      t.timestamps
    end
  end
end
