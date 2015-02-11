class CreateWeeklyLogs < ActiveRecord::Migration
  def change
    create_table :weekly_logs do |t|
      t.json :data
      t.belongs_to :sensor, index: true
      t.timestamps
    end
  end
end
