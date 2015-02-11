class PopulateSubmittedAtOnWeeklyLogs < ActiveRecord::Migration
  class WeeklyLog < ActiveRecord::Base
  end

  def up
    WeeklyLog.reset_column_information

    WeeklyLog.find_each do |weekly_log|
      weekly_log.update(
        submitted_at: Time.at(weekly_log.data['ts'] / 1000.0).utc.to_datetime
      )
    end
  end

  def down
    # intentionally left blank
  end
end
