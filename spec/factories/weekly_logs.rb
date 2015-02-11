FactoryGirl.define do
  factory :weekly_log do
    sensor

    received_at 1.week.ago
    week_started_at { received_at.beginning_of_week(:sunday) }
    red_flag 0

    data do
      {
        'values' => {
          'weeklyLog' => {
            'dailyLogs' => []
          }
        }
      }
    end

    trait :out_of_band do
      red_flag WeeklyLog::OUT_OF_BAND_RED_FLAG
      data do
        {
          'values' => {
            'weeklyLog' => {
              'redFlag' => WeeklyLog::OUT_OF_BAND_RED_FLAG,
              'week' => 26,
              'unitID' => 1234,
              'dailyLogs' => [
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
                { 'liters' => [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], },
              ]
            }
          }
        }
      end
    end

    ignore do
      liters { nil }
    end

    after(:build) do |weekly_log, evaluator|
      if evaluator.liters.present?
        weekly_log.data = {
          'values' => {
            'weeklyLog' => {
              'dailyLogs' => evaluator.liters.map do |day’s_liters|
                liters = [0] * 24
                liters[(rand * 24).floor] = day’s_liters

                { 'liters' => liters }
              end
            }
          }
        }
      end
    end
  end
end
