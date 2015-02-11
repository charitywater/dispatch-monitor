require 'spec_helper'

feature 'List tickets' do
  given(:time) { DateTime.new(1982, 1, 2, 3, 4, 5) }

  scenario 'Viewing tickets list' do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as an admin'
      When 'I go to the tickets page'
      Then 'I can navigate between pages of tickets'
    end
  end

  scenario 'Viewing tickets list as single program viewer' do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a viewer'
      When 'I go to the tickets page'
      Then 'I can see tickets'
    end
  end

  scenario 'Viewing tickets list as a program manager' do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a program manager'
      When 'I go to the tickets page'
      Then 'I can see tickets'
    end
  end

  scenario 'Viewing ticket details' do
    Given 'There are tickets'
    And 'I am logged in as an admin'
    When 'I go to a ticket details page'
    Then 'I see details about my ticket'
  end

  scenario 'Viewing a ticket without a due date' do
    Given 'There is a ticket without a due date'
    And 'I am logged in as an admin'
    When 'I go to a ticket details page'
    Then 'I see details about my ticket without a due date'
  end

  given!(:program) {
    create(:program,
      country: create(:country, name: 'Fancy Australia'),
      partner: create(:partner, name: 'Fancy Partner'),
    )
  }
  given!(:program_manager) { create(:account, :program_manager, program: program) }
  given!(:viewer) { create(:account, :viewer, program: program) }

  def there_are_tickets
    happened_at = DateTime.new(1982, 1, 2)
    due_at = DateTime.new(1982, 2, 2)

    project = create(
      :project,
      id: 3000,
      program: program,
      deployment_code: 'AA.BBB.Q1.11.111.111',
      community_name: 'Fancy Community',
      latitude: '13.4277782440186',
      longitude: '-39.5366668701172',
      contact_name: 'Fancy Name',
      contact_email: 'fancy.email@example.com',
      contact_phone_numbers: [
        '+15555555555',
        '+41 44 364 35 33',
      ],
    )

    survey_response = create(
      :survey_response,
      :source_observation_v02_with_data,
      project: project,
    )

    create(
      :ticket,
      :in_progress,
      id: 1000,
      started_at: happened_at,
      due_at: due_at,
      survey_response: survey_response,
    )

    project = create(:project, deployment_code: 'AA.BBB.Q2.11.111.111', community_name: 'Dapper Community', program: program)
    create(:ticket, :complete, id: 1001, survey_response: create(:survey_response, :source_observation_v1, project: project))

    create(:ticket, :complete, id: 1002)
    create(:ticket, :complete, id: 1003)
    create(:ticket, :complete, id: 1004)
    create(:ticket, :complete, id: 1005)
    create(:ticket, :complete, id: 1006)

    project = create(:project, deployment_code: 'AA.CCC.Q2.11.111.111', community_name: 'Dapper Community', program: program)
    create(:ticket, :complete, id: 1007, survey_response: create(:survey_response, :source_observation_v02, project: project))
  end

  def there_is_a_ticket_without_a_due_date
    project = create(:project, community_name: 'Fancy Community')

    survey_response = create(
      :survey_response,
      :source_observation_v02,
      project: project,
    )

    create(
      :ticket,
      :in_progress,
      id: 1000,
      due_at: nil,
      survey_response: survey_response,
    )
  end

  def i_go_to_the_tickets_page
    visit root_path
    click_link 'Tickets'

    expect(page).to have_css('h1', text: 'Tickets')
    expect(page).to have_content 'Due Date'
  end

  def i_can_navigate_between_pages_of_tickets
    expect(page).to have_content 'Fancy Community'
    expect(page).to have_content 'In Progress'
    expect(page).to have_content 'AA.BBB.Q1.11.111.111'

    expect(page).to have_content 'Dapper Community'
    expect(page).to have_content 'Complete'
    expect(page).to have_content 'AA.BBB.Q2.11.111.111'

    expect(page).not_to have_content 'AA.CCC.Q2.11.111.111'

    click_first_link 'Next'

    expect(page).to have_content 'AA.CCC.Q2.11.111.111'
    expect(page).not_to have_content 'AA.BBB.Q1.11.111.111'
    expect(page).not_to have_content 'AA.BBB.Q2.11.111.111'

    click_first_link 'First'

    expect(page).to have_content 'AA.BBB.Q1.11.111.111'
    expect(page).to have_content 'AA.BBB.Q2.11.111.111'
    expect(page).not_to have_content 'AA.CCC.Q2.11.111.111'
  end

  def i_can_see_tickets
    expect(page).to have_content 'Fancy Community'
    expect(page).to have_content 'In Progress'
    expect(page).to have_content 'AA.BBB.Q1.11.111.111'

    expect(page).to have_content 'Dapper Community'
    expect(page).to have_content 'Complete'
    expect(page).to have_content 'AA.BBB.Q2.11.111.111'
  end

  def i_go_to_a_ticket_details_page
    visit root_path
    click_link 'Tickets'
    click_link '1000'

    expect(page).to have_css('h1', text: 'Ticket #1')
  end

  def i_see_details_about_my_ticket
    expect(page).to have_content 'Fancy Community'
    expect(page).not_to have_content 'Dapper Community'
    expect(page).to have_content 'Fancy Australia'
    expect(page).to have_content 'Fancy Name'
    expect(page).to have_content 'fancy.email@example.com'
    expect(page).to have_content '+15555555555'
    expect(page).to have_content '+41 44 364 35 33'

    expect(page).to have_content 'Due Date 1982-02-02'
    expect(page).to have_content 'Completion Date —'
    expect(page).to have_content 'GPS 13.427778, -39.536667'
    expect(page).to have_content 'Is it functional? Yes'
    expect(page).to have_content 'Is H2O being consumed? Unknown / Unable to Answer'
    expect(page).to have_content 'Is a maintenance visit required? No'
    expect(page).to have_content 'Other Notes The local mechanic repaired it.'

    expect(page).to have_link('Map', href: map_project_path(3000))
  end

  def i_see_details_about_my_ticket_without_a_due_date
    expect(page).to have_content 'Fancy Community'
    expect(page).to have_content 'Due Date —'
  end
end
