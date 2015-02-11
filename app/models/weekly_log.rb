class WeeklyLog < ActiveRecord::Base
  has_paper_trail

  belongs_to :sensor
  has_one :project, through: :sensor
  has_one :ticket

  validates :sensor_id, presence: true

  after_create :cache_sensor_daily_average, :cache_sensor_uptime

  OUT_OF_BAND_RED_FLAG = 255

  def self.since(date)
    where('week_started_at >= ?', date.beginning_of_week(:sunday))
  end

  def self.out_of_band
    where(red_flag: OUT_OF_BAND_RED_FLAG)
  end

  def self.in_band
    where.not(red_flag: OUT_OF_BAND_RED_FLAG)
  end

  def device_id
    data['deviceId']
  end

  def daily_logs
    weekly_log['dailyLogs']
  end

  def liters_by_day
    @liters_by_day ||= daily_logs.map do |daily_log|
      daily_log['liters'].sum
    end
  end

  def total_liters
    @total_liters ||= liters_by_day.sum
  end

  def normal_flow?
    !out_of_band? && daily_logs.all? { |daily_log| daily_log['redFlag'].zero? }
  end

  def out_of_band?
    red_flag == OUT_OF_BAND_RED_FLAG
  end

  def has_out_of_band_pair?
    !out_of_band? && sensor.weekly_logs.out_of_band.where(
      week_started_at: week_started_at,
      unit_id: unit_id,
    ).any?
  end

  private

  def weekly_log
    data['values']['weeklyLog']
  end

  def cache_sensor_daily_average
    return if out_of_band?

    cached_average_liters = sensor.daily_average_liters || 0
    cached_days_for_average_liters = sensor.days_for_daily_average_liters || 0

    cached_liters = cached_average_liters * cached_days_for_average_liters
    num_days = daily_logs.count + cached_days_for_average_liters

    sensor.update(
      daily_average_liters: (cached_liters + total_liters) / num_days.to_f,
      days_for_daily_average_liters: num_days
    )
  end

  def cache_sensor_uptime
    sensor.update(uptime: week)
  end
end
