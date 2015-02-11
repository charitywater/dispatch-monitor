class ChangeDateToDatetimeOnActivities < ActiveRecord::Migration
  def up
    change_column :activities, :date, :datetime
    rename_column :activities, :date, :happened_at
  end

  def down
    rename_column :activities, :happened_at, :date
    change_column :activities, :date, :date
  end
end
