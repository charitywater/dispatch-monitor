class MigrateStatusChangedActivities < ActiveRecord::Migration
  class Activity < ActiveRecord::Base
    BECAME_BROKEN = 3
    BECAME_WORKING = 4
    BECAME_INACTIVE = 5

    STATUS_CHANGED = 3
  end

  def up
    reset_column_information

    Activity.where(activity_type: Activity::BECAME_BROKEN)
      .update_all(activity_type: Activity::STATUS_CHANGED, data: { status: :broken })

    Activity.where(activity_type: Activity::BECAME_WORKING)
      .update_all(activity_type: Activity::STATUS_CHANGED, data: { status: :working })

    Activity.where(activity_type: Activity::BECAME_INACTIVE)
      .update_all(activity_type: Activity::STATUS_CHANGED, data: { status: :inactive })
  end

  def down
    reset_column_information

    Activity.where(activity_type: Activity::STATUS_CHANGED)
      .where("data->>'status' = ?", :broken)
      .update_all(activity_type: Activity::BECAME_BROKEN, data: {})

    Activity.where(activity_type: Activity::STATUS_CHANGED)
      .where("data->>'status' = ?", :working)
      .update_all(activity_type: Activity::BECAME_WORKING, data: {})

    Activity.where(activity_type: Activity::STATUS_CHANGED)
      .where("data->>'status' = ?", :inactive)
      .update_all(activity_type: Activity::BECAME_INACTIVE, data: {})
  end

  private

  def reset_column_information
    Activity.reset_column_information
  end
end
