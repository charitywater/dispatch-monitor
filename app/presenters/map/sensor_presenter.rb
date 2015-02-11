module Map
  class SensorPresenter < Presenter
    def as_json(*_)
      {
        id: id,
        project_id: project_id,
        graph_data: graph_data.map(&:as_json),
      }
    end

    def graph_data
      liters_per_day = initial_liters_per_day

      recent_weekly_logs.each do |weekly_log|
        beginning_of_week = weekly_log.week_started_at.beginning_of_day
        weekly_log.daily_logs.each_with_index do |day, index|
          date = beginning_of_week + index.days
          liters_per_day[date] = day['liters'].sum if liters_per_day.key?(date)
        end
      end

      liters_per_day.map do |date, liters|
        { date: date, liters: liters }
      end
    end

    private

    def recent_weekly_logs
      weekly_logs.in_band.since(5.weeks.ago)
    end

    def initial_liters_per_day
      now = Time.zone.now.beginning_of_day
      date_range = 27.downto(0)

      date_range.map do |day_offset|
        [ now - day_offset.days, 0 ]
      end.to_h
    end

    alias_method :sensor, :__getobj__
  end
end
