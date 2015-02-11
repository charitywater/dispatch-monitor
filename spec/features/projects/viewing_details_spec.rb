require 'spec_helper'

feature 'Viewing project details' do
  before do
    Timecop.travel DateTime.new(2010, 1, 8, 3, 0, 0, '+0')
  end

  after do
    Timecop.return
  end

  scenario 'Viewing project details', :js do
    Given 'There is a project'
    And 'I am logged in as an admin'
    When 'I click on the project in the list'
    Then 'I see the project details'
  end

  scenario 'Viewing project edit and delete buttons', :js do
    Given 'There is a project'
    And 'I am logged in as a viewer'
    When 'I click on the project in the list'
    Then 'I cant see the edit and delete buttons'
  end

  given!(:viewer) { create(:account, :viewer, program: nil) }

  def there_is_a_project
    program = create(
      :program,
      country: create(:country, name: 'Fancy Australia'),
      partner: create(:partner, name: 'Fancy Partner'),
    )

    project = create(
      :project,
      :flowing,
      id: 3000,
      program: program,
      deployment_code: 'FA.NCY.Q1.01.001.001',
      region: 'Fancy Region',
      district: 'Fancy District',
      community_name: 'Fancy Community',
      site_name: 'Fancy Site',
      completion_date: '1950-01-01',
      contact_name: 'sb',
      contact_email: 'saqib.bedi@charitywater.org',
      contact_phone_numbers: ['1234567890'],
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

    sensor = create(:sensor, project: project)

    create(
      :weekly_log,
      sensor: sensor,
      liters: [80000, 0, 0, 0, 0, 0, 0],
      received_at: DateTime.rfc2822('Fri, 8 Jan 2010 05:00:00 +0000')
    )
  end

  def i_click_on_the_project_in_the_list
    visit root_path
    click_on 'Projects'

    expect(page).to have_content('Fancy Region')
    expect(page).to have_content('Fancy District')
    expect(page).to have_content('Fancy Community')
    expect(page).to have_content('Fancy Site')

    click_on 'FA.NCY.Q1.01.001.001'
  end

  def i_see_the_project_details
    expect(page).to have_content(/fancy community/i)
    expect(page).to have_content(/fancy australia/i)
    expect(page).to have_content 'FA.NCY.Q1.01.001.001'
    expect(page).to have_content 'Fancy Partner'
    expect(page).to have_content 'Flowing'
    expect(page).to have_content 'sb'
    expect(page).to have_content 'saqib.bedi@charitywater.org'
    expect(page).to have_content '1234567890'

    expect(page).to have_content(/activity/i)
    expect(page).to have_content(/1950-01-01\s?Construction complete/)

    expect(page).to have_content(/tickets/i)
    expect(page).to have_content 'Due on 1950-01-02 #40000 Overdue'
    expect(page).to have_content 'Completed on 1949-01-02 #40001 Complete'
    expect(page).to have_content 'Due on 9000-01-01 #40002 In Progress'
    expect(page).to have_content 'Started on 2000-01-01 #40003 In Progress'
    expect(page).to have_link('#40000 Overdue', href: ticket_path(40000))
    expect(page).to have_link('#40001 Complete', href: ticket_path(40001))

    within '.sensor-graph' do
      expect(page).not_to have_content(/'?undefined'? is not a function/)
      expect(page).to have_content(/\dKL/)
    end

    expect(page).to have_link('Edit', href: edit_project_path(3000))
    expect(page).to have_link('Delete', href: project_path(3000))
    expect(page).to have_link('+ Ticket', href: new_project_ticket_path(3000))
  end

  def i_cant_see_the_edit_and_delete_buttons
    expect(page).not_to have_link('Edit', href: edit_project_path(3000))
    expect(page).not_to have_link('Delete', href: project_path(3000))
    expect(page).not_to have_link('+ Ticket', href: new_project_ticket_path(3000))
  end
end
