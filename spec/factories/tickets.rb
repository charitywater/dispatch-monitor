FactoryGirl.define do
  factory :ticket do
    project do
      if __override_names__.include?(:survey_response) && survey_response
        survey_response.project
      else
        FactoryGirl.create(:project)
      end
    end

    started_at { Time.zone.now.beginning_of_day }
    due_at { started_at + 30.days }
    deleted_at nil
    status :in_progress

    trait :in_progress do
      status :in_progress
    end

    trait :complete do
      status :complete
    end

    trait :overdue do
      status :in_progress
      started_at { 3.years.ago }
    end

    trait :deleted do
      deleted_at { Time.zone.now }
    end

    trait :due_today do
      status :in_progress
      due_at { started_at + 1.minute }
    end
  end
end
