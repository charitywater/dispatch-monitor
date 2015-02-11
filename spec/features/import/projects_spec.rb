require 'spec_helper'

feature 'Import projects', :vcr do
  scenario 'Importing projects' do
    Given 'A project exists on WAZI'
    And 'I am logged in as an admin'
    When 'I import a list of projects'
    Then 'I see the imported projects'
    And 'I see an email with the results'
  end

  scenario 'Importing existing projects' do
    Given 'A project exists on WAZI'
    And 'I am logged in as an admin'
    And 'The project also exists in the app'
    When 'I import a list of projects'
    Then 'I see the imported projects'
  end

  scenario 'Creating activity stream', :js do
    Given 'A project exists on WAZI'
    And 'I am logged in as an admin'
    When 'I import a list of projects'
    Then 'I can see its activity stream'
  end

  scenario 'Updating activity stream', :js do
    Given 'A project exists on WAZI'
    And 'I am logged in as an admin'
    And 'The project also exists in the app'
    When 'I import a list of projects'
    Then 'I can see its activity stream'
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

  before do
    clear_emails
  end

  def a_project_exists_on_wazi
    # VCR requests
  end

  def i_import_a_list_of_projects
    visit root_path
    click_link 'Projects'
    click_link '+ Projects'

    fill_in 'Import codes', with: <<-CODES.strip_heredoc
      ET.GOH.Q4.09.048.123
      UG.LWT.Q1.08.022
      LR.CON.Q2.07.004.001
      BD.CON.Q3.12.125.218
    CODES

    click_on 'Import'
  end

  def i_see_the_imported_projects
    expect(page).to have_content 'Gereb Serdi'
    expect(page).to have_content 'Barzewein'
    expect(page).to have_content 'Ouka'

    expect(page).to have_select 'Program', with_options: [
      'Relief Society of Tigray – Ethiopia',
      'Lifewater International – Uganda',
      'Concern Worldwide U.S. – Bangladesh',
      'Concern Worldwide U.S. – Liberia',
    ]
  end

  def i_can_see_its_activity_stream
    click_first_link 'ET.GOH.Q4.09.048.123'

    expect(page).to have_content(/activity/i)
    expect(page).to have_content(/2011-07-02\s?Construction complete/)
    expect(page).not_to have_content(/2011-07-02\s?Construction complete.*2011-07-02 Construction complete/)
  end

  def the_project_also_exists_in_the_app
    program = create(
      :program,
      country: create(:country, name: 'Ethiopia'),
      partner: create(:partner, name: 'Relief Society of Tigray'),
    )
    project = create(
      :project,
      program: program,
      deployment_code: 'ET.GOH.Q4.09.048.123',
      wazi_id: 47,
      community_name: 'Old 1st Project',
      completion_date: '2011-07-02'
    )
    create(:activity, :completed_construction, happened_at: '2011-07-02', project: project)
  end

  def i_see_an_email_with_the_results
    open_email(admin.email)

    expect(current_email).to have_content 'Dear Admin Powers,'
    expect(current_email).to have_content 'projects were created'
    expect(current_email).to have_content 'ET.GOH.Q4.09.048.123'
    expect(current_email).to have_content 'UG.LWT.Q1.08.022.001'
    expect(current_email).to have_content 'UG.LWT.Q1.08.022.020'
    expect(current_email).not_to have_content 'projects were updated'
    expect(current_email).not_to have_content 'projects were invalid'

    expect(emails_sent_to(unsubscribed.email).length).to eq 0
    expect(emails_sent_to('test@example.com').length).to eq 0
  end
end
