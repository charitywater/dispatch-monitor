FactoryGirl.define do
  factory :survey_response do
    sequence(:fs_response_id) { |n| 1000 + n }
    sequence(:submitted_at) { |n| 10.days.ago + n.minutes }

    fs_survey_id 29

    project
    source_observation_v02

    response do
      { '_id' => fs_response_id }
    end

    %i(
      source_observation_v1
      source_observation_v02
      maintenance_report_v02
      test_source_observation_v1
      test_source_observation_v02
      test_maintenance_report_v02
    ).each do |type|
      trait type do
        survey_type type
      end
    end

    trait :source_observation_v02_with_data do
      source_observation_v02

      response do
        {
          '_id' => fs_response_id,
          'PV5RcUw2ys' => 'Yes',
          '5pXGXZwpaI' => 'Unknown / Unable to Answer',
          'LkUlwEuUwP' => 'No',
          '8Fxk9mToOG' => 'The local mechanic repaired it.',
        }
      end
    end
  end
end
