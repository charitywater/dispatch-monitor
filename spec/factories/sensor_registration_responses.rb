FactoryGirl.define do
  factory :sensor_registration_response do
    sequence(:fs_response_id) { |n| 1000 + n }
    sequence(:submitted_at) { |n| 10.days.ago + n.minutes }

    fs_survey_id 68483

    sensor_registration_afd1

    response do
      { '_id' => fs_response_id }
    end

    %i(sensor_registration_afd1).each do |type|
      trait type do
        survey_type type
      end
    end
  end
end
