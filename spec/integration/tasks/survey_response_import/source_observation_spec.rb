require 'spec_helper'

describe 'rake survey_response_import:source_observation', :vcr do
  before do
    @fluid_surveys_response_limit = ENV['FLUID_SURVEYS_LIMIT']
    ENV['FLUID_SURVEYS_LIMIT'] = '50'
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = 'true'

    create(:email_subscription, :bulk_import_notifications, account: admin)

    clear_emails
  end

  let!(:admin) { create(:account, :admin, email: 'admin@example.com') }

  after do
    ENV['FLUID_SURVEYS_LIMIT'] = @fluid_surveys_response_limit
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = nil
  end

  it 'performs the import correctly' do
    Rake::Task['survey_response_import:source_observation'].reenable
    Rake::Task['survey_response_import:source_observation'].invoke(:source_observation_v1, :test_source_observation_v02)

    expect(SurveyResponse.count).to be > 0

    expect(Country.pluck(:name)).to match_array %w(Ethiopia Liberia Nepal Uganda)
    expect(Partner.pluck(:name)).to match_array [
      'Lifewater International',
      'The International Lifeline Fund',
      'Concern Worldwide U.S.',
      'Nepal Water for Health',
      'Relief Society of Tigray',
    ]

    ug = Country.find_by(name: 'Uganda')
    ug_programs = Program.where(country_id: ug)

    expect(Program.count).to be >= Partner.count
    expect(ug_programs.map(&:partner).map(&:name)).to match_array [
      'Lifewater International',
      'The International Lifeline Fund'
    ]

    expect(Project.flowing.count).to be > 0
    expect(Project.needs_maintenance.count).to be > 0
    expect(Project.needs_visit.count).to be > 0
    expect(Project.unknown.count).to eq 0

    expect(Activity.completed_construction.count).to be > 0
    expect(Activity.observation_survey_received.count).to be > 0
    expect(Activity.status_changed_to_needs_maintenance.count).to be > 0
    expect(Activity.status_changed_to_flowing.count).to be > 0
    expect(Activity.status_changed_to_needs_visit.count).to be > 0

    expect(Ticket.count).to be > 0

    expect(emails_sent_to(admin.email).count).to eq 1
    open_email(admin.email)
    expect(current_email.subject).to eq '[test] Your Source Observation import has finished'
  end
end
