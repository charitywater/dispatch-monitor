require 'spec_helper'

describe 'rake survey_response_import:maintenance_report', :vcr do
  before do
    @fluid_surveys_response_limit = ENV['FLUID_SURVEYS_LIMIT']
    ENV['FLUID_SURVEYS_LIMIT'] = '50'
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = 'true'

    project = create(:project, :needs_maintenance, deployment_code: 'ET.GOH.Q4.09.048.230')
    survey_response = create(:survey_response, :source_observation_v1, project: project, submitted_at: DateTime.new(2013))
    create(:ticket, :in_progress, survey_response: survey_response, started_at: survey_response.submitted_at)
    create(:email_subscription, :bulk_import_notifications, account: admin)

    clear_emails
  end

  let!(:admin) { create(:account, :admin, email: 'admin@example.com') }

  after do
    ENV['FLUID_SURVEYS_LIMIT'] = @fluid_surveys_response_limit
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = nil
  end

  it 'performs the import correctly' do
    Rake::Task['survey_response_import:maintenance_report'].reenable
    Rake::Task['survey_response_import:maintenance_report'].invoke(:test_maintenance_report_v02)

    count = SurveyResponse.where(survey_type: 'test_maintenance_report_v02').count
    expect(count).to be > 0
    expect(Project.find_by(deployment_code: 'ET.GOH.Q4.09.048.230')).to be_inactive

    expect(Activity.maintenance_report_received.count).to be > 0
    expect(Activity.status_changed_to_inactive.count).to be > 0
    expect(
      Activity.maintenance_report_received.count +
      Activity.status_changed_to_inactive.count
    ).to eq Activity.count

    expect(Ticket.count).to be > 0
    expect(Ticket.first).to be_complete

    expect(emails_sent_to(admin.email).count).to eq 1
    open_email(admin.email)
    expect(current_email.subject).to eq '[test] Your Maintenance Report import has finished'
  end
end
