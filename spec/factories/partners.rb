FactoryGirl.define do
  factory :partner do
    sequence(:name) { |n| "Partner #{n}" }
  end
end
