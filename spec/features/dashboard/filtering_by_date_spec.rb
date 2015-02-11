require 'spec_helper'

feature 'Dashboard: Filtering by Date' do
  scenario 'Changing date window', :js do
    Given 'There are multiple survey responses'
    And 'I am logged in as an admin'
    When 'I change the Days field'
    Then 'I see only survey responses from those days'

    When 'I remove the program filter and change the days again'
    Then 'I see all survey responses from those days'
  end

  def there_are_multiple_survey_responses
    partner = create(:partner, name: 'Eau')
    country = create(:country, name: 'France')
    program = create(:program, country: country, partner: partner)

    create(:survey_response, submitted_at: 20.days.ago, survey_type: :maintenance_report_v02, project: create(:project, program: program))
    create(:survey_response, submitted_at: 10.days.ago, survey_type: :source_observation_v1, project: create(:project, program: program))
    create(:survey_response, submitted_at: 31.days.ago, survey_type: :source_observation_v02, project: create(:project, program: program))
    create(:survey_response, submitted_at: 2.days.ago, survey_type: :test_maintenance_report_v02)
  end

  def i_change_the_days_field
    visit root_path
    expect(page).to have_content(/3 field visits/i)
    expect(page).to have_content(/1\s?observation/i)
    expect(page).to have_content(/2\s?maintenance/i)
    expect(page).to have_content(/settings filter last 30 days/i)

    select 'Eau – France'

    expect(page).to have_content(/2 field visits/i)
    expect(page).to have_content(/1\s?observation/i)
    expect(page).to have_content(/1\s?maintenance/i)
    expect(page).to have_content(/settings filter last 30 days/i)

    within('#dashboard') { click_on 'Settings' }
    expect(page).to have_field 'Days'

    fill_in 'Days', with: 15
    click_on 'Save'
  end

  def i_see_only_survey_responses_from_those_days
    expect(page).not_to have_field 'Days'
    expect(page).to have_content(/1 field visit\b/i)
    expect(page).to have_content(/1\s?observation/i)
    expect(page).to have_content(/0\s?maintenance/i)
    expect(page).to have_content(/settings filter last 15 days/i)
    expect(current_url).to include('%255Bdays%255D=15')
  end

  def i_remove_the_program_filter_and_change_the_days_again
    select '[All Programs]'
    expect(page).to have_content(/2 field visits/i)
    expect(page).to have_content(/1\s?observation/i)
    expect(page).to have_content(/1\s?maintenance/i)
    expect(page).to have_content(/settings filter last 15 days/i)

    within('#dashboard') { click_on 'Settings' }
    expect(page).to have_field 'Days'

    fill_in 'Days', with: 30
    click_on 'Save'
  end

  def i_see_all_survey_responses_from_those_days
    expect(page).not_to have_field 'Days'
    expect(page).to have_content(/3 field visits/i)
    expect(page).to have_content(/1\s?observation/i)
    expect(page).to have_content(/2\s?maintenance/i)
    expect(page).to have_content(/settings filter last 30 days/i)
  end
end
