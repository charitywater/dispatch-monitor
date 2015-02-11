FactoryGirl.define do
  factory :sensor do
    sequence(:device_id) { |n| n }
    sequence(:imei) { |n| n }
    project
  end
end
