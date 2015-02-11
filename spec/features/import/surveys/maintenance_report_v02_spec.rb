require 'spec_helper'

feature 'Import maintenance surveys', :vcr do
  before do
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = 'true'
    clear_emails

    Timecop.travel DateTime.new(2014)
  end

  after do
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = nil

    Timecop.return
  end

  scenario 'Importing Maintenance Report V.02 Surveys', :js do
    Given 'A survey response for an existing project'
    And 'I am logged in as an admin'
    When 'I import the Maintenance Report V.02 survey'
    Then 'I see the updated ticket and project'
    And 'I see an email with the results'
  end

  given!(:admin) do
    create(:account, :admin, name: 'Admin Powers', email: 'admin@example.com')
  end
  given!(:subscription) do
    create(
      :email_subscription,
      account: admin,
      subscription_type: :bulk_import_notifications
    )
  end
  given!(:unsubscribed) { create(:account, :admin, email: 'other@example.com') }

  def a_survey_response_for_an_existing_project
    project = create(:project, :needs_maintenance, deployment_code: 'ET.GOH.Q4.09.048.230', community_name: 'New New York')
    survey_response = create(:survey_response, :maintenance_report_v02, project: project, submitted_at: 20.days.ago)
    create(:ticket, :in_progress, id: 12345, survey_response: survey_response, started_at: 20.days.ago)
  end

  def i_import_the_maintenance_report_v02_survey
    visit root_path

    click_link 'Projects'
    click_link '+ Surveys'
    click_button 'Import Maintenance Report V.02 (Test)'
    expect(page).not_to have_button 'Import Maintenance Report V.02 (Test)'
  end

  def i_see_the_updated_ticket_and_project
    click_on 'Tickets'

    expect(page).to have_content 'ET.GOH.Q4.09.048.230'

    within 'table' do
      expect(page).not_to have_content 'In Progress'
      expect(page).to have_content 'Complete'
    end

    click_on '12345'

    within '#ticket' do
      expect(page).to have_link 'Map'
      click_on 'Map'
    end

    expect(page).not_to have_content 'Flowing'
    expect(page).not_to have_content 'Needs Maintenance'
    expect(page).not_to have_content 'Unknown'
    expect(page).to have_content(/Status\s?Inactive/)

    expect(page).to have_css 'a[href^="https://charitywater.fluidsurveys.com"]', text: 'Maintenance report'
    expect(page).to have_content(/2014-06-30\s?Inactive\s?2014-06-30\s?Maintenance report/)
  end

  def i_see_an_email_with_the_results
    open_email(admin.email)

    expect(current_email).to have_content 'Maintenance Report V.02'
    expect(current_email).to have_content(/\d+ repairs were completed/)
    expect(current_email).to have_content(/\d+ repairs were not completed/)
    expect(current_email).to have_content(/\d+ projects are inactive/)
    expect(current_email).to have_content 'ET.GOH.Q4.09.048.230'

    expect(emails_sent_to(unsubscribed.email).length).to eq 0
    expect(emails_sent_to('test@example.com').length).to eq 0
  end
end
