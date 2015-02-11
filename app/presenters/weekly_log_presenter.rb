class WeeklyLogPresenter < Presenter
  def formatted_gmt_time
    data = weekly_log.data
    weekly = data["values"]["weeklyLog"]
    "#{weekly['GMTmonth']}/#{weekly['GMTday']}/#{weekly['GMTyear']} #{weekly['GMThour']}:#{weekly['GMTminute']}:#{weekly['GMTsecond']}"
  end

  def formatted_data
    weekly_log.data["values"]["weeklyLog"]["dailyLogs"]
  end

  private

  alias_method :weekly_log, :__getobj__
end
