class UseProjectStatusEnumInActivities < ActiveRecord::Migration
  class Activity < ActiveRecord::Base
    STATUS_CHANGED = 3
  end

  class Project < ActiveRecord::Base
    enum status: {
      unknown: 0,
      broken: 1,
      working: 2,
      inactive: 3,
      needs_visit: 4,
    }
  end

  def up
    reset_column_information

    Project.statuses.each do |key, value|
      Activity.where(activity_type: Activity::STATUS_CHANGED)
        .where("data->>'status' = ?", key)
        .update_all(data: { status: value })
    end
  end

  def down
    reset_column_information

    Project.statuses.each do |key, value|
      Activity.where(activity_type: Activity::STATUS_CHANGED)
        .where("data->>'status' = ?", value)
        .update_all(data: { status: key })
    end
  end

  private

  def reset_column_information
    [Activity, Project].each(&:reset_column_information)
  end
end
