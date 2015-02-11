require 'spec_helper'

feature 'List projects' do
  scenario 'Viewing a list of projects', :js do
    Given 'There are many projects'
    And 'I am logged in as an admin'
    When 'I am viewing the list of projects'
    Then 'I can navigate between pages of projects'
  end

  def there_are_many_projects
    create_list(:project, 3, :flowing)
    create_list(:project, 2, :needs_maintenance)
    create_list(:project, 6, :unknown)

    program = create(
      :program,
      country: create(:country, name: 'Fancy Australia'),
      partner: create(:partner, name: 'Fancy Partner'),
    )

    project = create(
      :project,
      :flowing,
      program: program,
      deployment_code: 'FA.NCY.Q1.01.001.001',
      region: 'Fancy Region',
      district: 'Fancy District',
      community_name: 'Fancy Community',
      site_name: 'Fancy Site',
      completion_date: '1950-01-01',
      activities: [create(:activity, :completed_construction, happened_at: '1950-01-01')]
    )

    create(
      :ticket,
      :in_progress,
      id: 40000,
      survey_response: create(:survey_response, project: project),
      started_at: DateTime.new(1948, 1, 2),
      due_at: DateTime.new(1950, 1, 2)
    )

    create(
      :ticket,
      :complete,
      id: 40001,
      survey_response: create(:survey_response, project: project),
      started_at: DateTime.new(1948, 1, 2),
      completed_at: DateTime.new(1949, 1, 2)
    )

    create(
      :ticket,
      :in_progress,
      id: 40002,
      survey_response: create(:survey_response, project: project),
      started_at: DateTime.new(1948, 1, 2),
      due_at: DateTime.new(9000, 1, 1),
    )

    create(
      :ticket,
      :in_progress,
      id: 40003,
      survey_response: create(:survey_response, project: project),
      started_at: DateTime.new(2000, 1, 1),
      due_at: nil,
    )
  end

  def i_am_viewing_the_list_of_projects
    visit root_path
    click_on 'Projects'
  end

  def i_can_navigate_between_pages_of_projects
    expect(page).to have_content 'AA.AAA.A1.11.111.001'
    expect(page).to have_content 'Flowing'

    expect(page).to have_content 'AA.AAA.A1.11.111.005'
    expect(page).to have_content 'Needs Maintenance'

    expect(page).not_to have_content 'AA.AAA.A1.11.111.006'
    expect(page).not_to have_content 'Unknown'

    click_first_link 'Next'

    expect(page).not_to have_content 'AA.AAA.A1.11.111.005'
    expect(page).not_to have_content 'Flowing'
    expect(page).not_to have_content 'Needs Maintenance'

    expect(page).to have_content 'AA.AAA.A1.11.111.006'
    expect(page).to have_content 'AA.AAA.A1.11.111.010'
    expect(page).to have_content 'Unknown'

    expect(page).not_to have_content 'AA.AAA.A1.11.111.011'

    click_first_link 'Last'

    expect(page).not_to have_content 'AA.AAA.A1.11.111.010'
    expect(page).to have_content 'AA.AAA.A1.11.111.011'

    click_first_link 'First'

    expect(page).to have_content 'AA.AAA.A1.11.111.005'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.011'
  end
end
