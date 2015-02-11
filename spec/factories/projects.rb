FactoryGirl.define do
  factory :project do
    sequence(:wazi_id) { |n| n }
    sequence(:deployment_code) { |n| "AA.AAA.A1.11.111.#{n.to_s.rjust(3, '0')}" }
    latitude { 50.2 }
    longitude { -97.3 }
    status :unknown

    program

    Project.statuses.each do |s, _|
      trait s.to_sym do
        status s
      end
    end
  end
end
