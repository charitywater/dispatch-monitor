require 'spec_helper'

feature 'Import observation surveys', :vcr do
  before do
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = 'true'
    clear_emails
    Kaminari.config.default_per_page = 30
  end

  after do
    ENV['TEST_ONLY__FLUID_SURVEYS_CLIENT_SKIP_PAGING'] = nil
    Kaminari.config.default_per_page = 5
  end

  scenario 'Importing Source Observation V1 surveys', :js do
    Given 'A survey response for an existing project'
    And 'I am logged in as an admin'
    When 'I import the observation v1 survey'
    Then 'I see the updated project'
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
    project = create(:project, :unknown, deployment_code: 'UG.LWT.Q1.08.022.020', inventory_type: 'Fake')
    create(:activity, :completed_construction, happened_at: '2001-02-03', project: project)
    create(:activity, :completed_construction, happened_at: '1999-02-03', project: project)
    create(:activity, :completed_construction, happened_at: '2003-02-03', project: project)
  end

  def i_import_the_observation_v1_survey
    visit root_path

    click_link 'Projects'
    click_link '+ Surveys'
    click_button 'Import Source Observation V1'
  end

  def i_see_the_updated_project
    click_on 'Projects'

    expect(page).to have_content 'UG.LWT.Q1.08.022.020'

    within 'table' do
      expect(page).not_to have_content 'Unknown'
      expect(page).to have_content 'Flowing'
    end

    click_on 'UG.LWT.Q1.08.022.020'

    expect(page).not_to have_content 'Unknown'
    expect(page).to have_content(/Status\s?Flowing/)

    expect(page).not_to have_content 'Fake'
    expect(page).to have_content(/India Mark II(?!I)/)

    expect(page).to have_css 'a[href^="https://charitywater.fluidsurveys.com"]', text: 'Observation survey'

    expect(page).to have_content(/2014-01-17\s?Flowing\s?2014-01-17\s?Observation survey/)
    expect(page).to have_content(/2014-01-17.*2003-02-03.*2001-02-03.*1999-02-03/)

    click_on 'Tickets'

    expect(page).to have_content(/Due Date/i)
    expect(page).to have_content 'Overdue'
    # needs_maintenance project
    expect(page).to have_content 'UG.ILF.Q1.09.037.64'
    expect(page).to have_content 'Akaidebe'
    # flowing project
    expect(page).not_to have_content 'UG.LWT.Q1.08.022.005'
    expect(page).not_to have_content 'Alip'
  end

  def i_see_an_email_with_the_results
    open_email('admin@example.com')

    expect(current_email).to have_content 'Source Observation V1'
    expect(current_email).to have_content 'survey responses were created'
    expect(current_email).to have_content 'projects need maintenance:'
    expect(current_email).to have_content 'LR.CON.Q1.11.075.019'

    expect(emails_sent_to(unsubscribed.email).length).to eq 0
    expect(emails_sent_to('test@example.com').length).to eq 0
  end
end
