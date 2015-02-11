FactoryGirl.define do
  factory :account do
    sequence(:name) { |n| "Person Q. the #{n.ordinalize}" }
    sequence(:email) { |n| "test#{n}@example.com" }
    password 'password123'

    trait :admin do
      role :admin
      program nil
    end

    trait :program_manager do
      role :program_manager
      program
    end

    trait :viewer do
      role :viewer
      program nil
    end
  end
end
