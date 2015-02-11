FactoryGirl.define do
  factory :email_subscription do
    bulk_import_notifications
    account

    trait :bulk_import_notifications do
      subscription_type :bulk_import_notifications
    end
  end
end
