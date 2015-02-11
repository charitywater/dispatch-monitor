FactoryGirl.define do
  factory :activity do
    sequence(:happened_at) { |n| 1.year.ago + n.days }
    activity_type :completed_construction
    data {}
    project

    Activity.activity_types.each do |t, _|
      trait(t.to_sym) { activity_type t }
    end

    Project.statuses.each do |s, _|
      trait("status_changed_to_#{s}".to_sym) do
        status_changed
        data(status: Project.statuses[s])
      end
    end
  end
end
