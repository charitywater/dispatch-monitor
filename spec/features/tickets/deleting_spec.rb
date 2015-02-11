require 'spec_helper'

feature 'List tickets' do
  scenario 'Admin can delete a ticket', :js do
    Given 'There are tickets'
    And 'I am logged in as an admin'
    When 'I delete a ticket'
    Then 'I do not see it in the tickets list'
  end

  scenario 'Program manager cannot delete a ticket' do
    Given 'There are tickets'
    And 'I am logged in as a program manager'
    When 'I view a ticket'
    Then 'I am unable to delete it'
  end

  scenario 'Viewer cannot delete a ticket' do
    Given 'There are tickets'
    And 'I am logged in as a viewer'
    When 'I view a ticket'
    Then 'I am unable to delete it'
  end

  given!(:program_manager) { create(:account, :program_manager, program: program) }
  given!(:program) { create(:program) }
  given!(:viewer) { create(:account, :viewer, program: program) }

  def there_are_tickets
    project = create(
      :project,
      id: 3000,
      community_name: 'Fancy Community',
      program: program,
    )

    create(
      :ticket,
      :in_progress,
      id: 50000,
      survey_response: create(:survey_response, :source_observation_v1, project: project),
    )

    project = create(:project, community_name: 'Dapper Community', program: program)
    create(
      :ticket,
      :complete,
      survey_response: create(:survey_response, :source_observation_v02, project: project),
    )
  end

  def i_delete_a_ticket
    i_view_a_ticket

    click_link 'Delete'
    accept_js_alert
  end

  def i_view_a_ticket
    visit root_path
    click_link 'Tickets'
    click_link '50000'
  end

  def i_do_not_see_it_in_the_tickets_list
    expect(page).to have_content 'Dapper Community'
    expect(page).not_to have_content 'Fancy Community'
  end

  def i_am_unable_to_delete_it
    expect(page).to have_content 'Fancy Community'
    expect(page).not_to have_content 'Dapper Community'

    expect(page).not_to have_link 'Delete'
  end
end
