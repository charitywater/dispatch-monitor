require 'spec_helper'

feature 'Decommissioning a project manually' do
  given(:time) { DateTime.new(1982, 1, 2, 3, 4, 5) }

  scenario 'Admin manually completes a ticket', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as an admin'
      When 'I decommission a ticket’s project'
      Then 'I see the inactive project'
    end
  end

  scenario 'Program manager can toggle ticket status', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a program manager'
      When 'I decommission a ticket’s project'
      Then 'I see the inactive project'
    end
  end

  scenario 'Viewer cant decomission projects', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a viewer'
      When 'I view a ticket'
      Then 'I am unable to decommission the project'
    end
  end

  given!(:program) { create(:program) }
  given!(:program_manager) { create(:account, :program_manager, program: program) }
  given!(:viewer) { create(:account, :viewer, program: program) }

  def there_are_tickets
    happened_at = DateTime.new(1982, 1, 2)
    due_at = DateTime.new(1982, 2, 2)
    project = create(
      :project,
      :needs_maintenance,
      id: 3000,
      deployment_code: 'AA.BBB.Q1.11.111.111',
      community_name: 'Fancy Community',
      program: program,
    )

    create(
      :ticket,
      :in_progress,
      id: 50000,
      started_at: happened_at,
      due_at: due_at,
      survey_response: create(:survey_response, :source_observation_v1, project: project),
    )

    project = create(
      :project,
      deployment_code: 'AA.BBB.Q2.11.111.111',
      community_name: 'Dapper Community',
      program: program,
    )
  end

  def i_decommission_a_tickets_project
    visit root_path
    click_link 'Tickets'
    click_link '50000'

    expect(page).to have_css('h1', text: 'TICKET #50000')
    expect(page).to have_content 'Due Date'

    expect(page).to have_content(/Status\s?In Progress/i)
    expect(page).to have_content(/Completion Date\s?—/i)
    expect(page).to have_content(/Current Status\s?Needs Maintenance/i)
    expect(page).not_to have_content(/Status\s?Complete/i)

    click_button 'Decommission'
    accept_js_alert
    expect(page).not_to have_button 'Decommission'
  end

  def i_see_the_inactive_project
    expect(page).not_to have_content(/Status\s?In Progress/i)
    expect(page).to have_content(/Status\s?Complete/i)
    expect(page).to have_content(/Completion Date\s?1982-01-02/i)
    expect(page).to have_content(/Current Status\s?Inactive/i)

    click_link 'Inactive'
    expect(page).not_to have_content(/Ticket #50000/i)
    expect(page).to have_content "Inactive (manually set by #{current_account.email})"
    expect(page).to have_content "#50000 Complete (manually completed by #{current_account.email})"
  end

  def i_view_a_ticket
    visit root_path
    click_link 'Tickets'
    click_link '50000'
  end

  def i_am_unable_to_decommission_the_project
    expect(page).to have_content 'Fancy Community'
    expect(page).not_to have_content 'Dapper Community'

    expect(page).not_to have_link 'Decommission'
  end
end
