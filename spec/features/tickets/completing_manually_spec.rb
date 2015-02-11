require 'spec_helper'

feature 'Completing tickets manually' do
  given(:time) { DateTime.new(1982, 1, 2, 3, 4, 5) }

  scenario 'Admin manually completes a ticket', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as an admin'
      When 'I complete a ticket'
      Then 'I see the completed ticket'
    end
  end

  scenario 'Program manager can toggle ticket status', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a program manager'
      When 'I complete a ticket'
      Then 'I see the completed ticket'
    end
  end

  scenario 'Viewer cant toggle ticket status', :js do
    Timecop.travel time do
      Given 'There are tickets'
      And 'I am logged in as a viewer'
      When 'I view a ticket'
      Then 'I dont see the complete ticket button'
    end
  end

  given!(:program) { create(:program) }
  given!(:program_manager) { create(:account, :program_manager, program: program) }
  given!(:viewer) { create(:account, :viewer, program: nil) }

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
    create(:ticket, :complete, id: 50001, survey_response: create(:survey_response, :source_observation_v02, project: project))

    create(:ticket, :complete, id: 50002)
    create(:ticket, :complete, id: 50003)
    create(:ticket, :complete, id: 50004)
    create(:ticket, :complete, id: 50005)
    create(:ticket, :complete, id: 50006)

    project = create(
      :project,
      deployment_code: 'AA.CCC.Q2.11.111.111',
      community_name: 'Dapper Community',
      program: program,
    )
    create(:ticket, :complete, id: 50007, survey_response: create(:survey_response, :source_observation_v1, project: project))
  end

  def i_view_a_ticket
    visit root_path
    click_link 'Tickets'
    click_link '50000'
    expect(page).not_to have_content(/You do not have permission/i)
  end

  def i_dont_see_the_complete_ticket_button
    expect(page).not_to have_button 'Complete'
  end

  def i_complete_a_ticket
    visit root_path
    click_link 'Tickets'
    click_link '50000'

    expect(page).to have_css('h1', text: 'TICKET #50000')
    expect(page).to have_content 'Due Date'

    expect(page).to have_content(/Status\s?In Progress/i)
    expect(page).to have_content(/Completion Date\s?—/i)
    expect(page).to have_content(/Current Status\s?Needs Maintenance/i)
    expect(page).not_to have_content(/Status\s?Complete/i)

    click_button 'Complete'
    accept_js_alert
    expect(page).not_to have_button 'Complete'
  end

  def i_see_the_completed_ticket
    expect(page).not_to have_content(/Status\s?In Progress/i)
    expect(page).to have_content(/Status\s?Complete/i)
    expect(page).to have_content(/Completion Date\s?1982-01-02/i)
    expect(page).to have_content(/Current Status\s?Flowing/i)
    expect(page).not_to have_button 'Re-open'

    click_link 'Flowing'
    expect(page).not_to have_content(/Ticket #50000/i)
    expect(page).to have_content "Flowing (manually set by #{current_account.email})"
    expect(page).to have_content "#50000 Complete (manually completed by #{current_account.email})"
  end
end
