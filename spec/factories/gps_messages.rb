FactoryGirl.define do
  factory :gps_message do
    esn { "0-11111111" }
    transmitted_at { Time.zone.now }
    payload { "0x001340D61C18440A00" }
  end
end
