require 'spec_helper'

feature 'Creating tickets manually' do
  scenario 'Admin creates ticket', :js do
    Given 'There is a flowing project'
    And 'I am logged in as an admin'
    When 'I manually create a ticket'
    Then 'I see the ticket and updated project'
  end

  scenario 'Admin creates invalid ticket' do
    Given 'There is a flowing project'
    And 'I am logged in as an admin'
    When 'I try to manually create an invalid ticket'
    Then 'I see the ticket errors'
  end

  scenario 'Admin tries to create ticket for needs maintenance project' do
    Given 'There is a project that needs maintenance'
    And 'I am logged in as an admin'
    When 'I visit the project list'
    Then 'I cannot create a ticket for the needs maintenance project'
  end

  scenario 'Program manager creates ticket', :js do
    Given 'There is a flowing project'
    And 'I am logged in as a program manager'
    When 'I manually create a ticket'
    Then 'I see the ticket and updated project'
  end

  scenario 'All program viewer cant create a ticket on project dashboard', :js do
    Given 'There is a flowing project'
    And 'I am logged in as a viewer'
    When 'I visit the project list'
    Then 'I dont see the option to create a ticket on the list'
  end

  scenario 'Viewer cant create a ticket on project dashboard', :js do
    Given 'There is a flowing project'
    And 'I am logged in as a viewer assigned to a program'
    When 'I visit the project list'
    Then 'I dont see the option to create a ticket on the list'
  end

  before do
    Timecop.travel DateTime.new(1960, 1, 1)
  end

  after do
    Timecop.return
  end

  given(:country) { create(:country, name: 'Fancy Australia') }
  given(:program) { create(:program, country: country) }
  given(:program_manager) { create(:account, :program_manager, email: 'pm@example.com', program: program) }
  given!(:viewer) { create(:account, :viewer, program: nil) }
  given!(:viewer_one_program) { create(:account, :viewer, program: program) }

  def there_is_a_flowing_project
    create(
      :project,
      :flowing,
      deployment_code: 'FA.NCY.Q1.11.111.111',
      community_name: 'Fancy Community',
      program: program,
    )
  end

  def i_manually_create_a_ticket
    click_on 'Projects'
    expect(page).to have_content 'Project Dashboard'

    click_on 'Create Ticket'
    expect(page).to have_content(/New Ticket for Fancy Community/i)
    expect(page).to have_content(/Fancy Australia/i)

    select 'Needs Maintenance', from: 'Project Status'
    fill_in 'Notes', with: 'Fancy Notes'

    click_on 'Create Ticket'
    expect(page).not_to have_button 'Create Ticket'
  end

  def i_see_the_ticket_and_updated_project
    expect(page).to have_content(/ticket #\d+/i)
    expect(page).to have_content(/fancy australia/i)

    expect(page).to have_content 'In Progress'
    expect(page).to have_content(/Start Date\s*1960-01-01/)
    expect(page).to have_content(/Due Date\s*1960-01-31/)

    expect(page).to have_content(/Community\s*Fancy Community/i)
    expect(page).to have_content(/Current Status\s*Needs Maintenance/i)

    expect(page).to have_content(/Is it functional\?\s*N\/A/)
    expect(page).to have_content(/Is H2O being consumed\?\s*N\/A/)
    expect(page).to have_content(/Is a maintenance visit required\?\s*N\/A/)

    expect(page).to have_content "Manually created by #{current_account.email}"
    expect(page).to have_content 'Fancy Notes'

    click_link 'Needs Maintenance'
    expect(page).not_to have_content(/ticket #\d+/i)

    expect(page).to have_content(/#\d+ In Progress \(manually created by #{current_account.email}\)/)
    expect(page).to have_content(/Needs Maintenance \(manually set by #{current_account.email}\)/)
    expect(page).not_to have_link('+ Ticket')
  end

  def i_try_to_manually_create_an_invalid_ticket
    click_on 'Projects'
    expect(page).to have_content 'Project Dashboard'

    click_on 'Create Ticket'
    expect(page).to have_content 'New Ticket for Fancy Community'
    expect(page).to have_content 'Fancy Australia'
    fill_in 'Notes', with: 'Fancy Notes'

    select '1962', from: 'ticket_started_at_1i'
    select 'February', from: 'ticket_started_at_2i'
    select '1', from: 'ticket_started_at_3i'

    select '1962', from: 'ticket_due_at_1i'
    select 'December', from: 'ticket_due_at_2i'
    select '31', from: 'ticket_due_at_3i'

    click_on 'Create Ticket'
  end

  def i_see_the_ticket_errors
    expect(page).to have_content 'There were one or more errors while trying to create the ticket.'

    %w(.ticket_started_at .ticket_due_at).each do |selector|
      within selector do
        expect(page).to have_content 'must be before two years from now'
      end
    end
  end

  def there_is_a_project_that_needs_maintenance
    create(
      :project,
      :needs_maintenance,
      community_name: 'Fancy Community',
      program: program,
    )
  end

  def i_visit_the_project_list
    click_on 'Projects'
    expect(page).to have_content 'Project Dashboard'
  end

  def i_cannot_create_a_ticket_for_the_needs_maintenance_project
    expect(page).not_to have_content 'Create Ticket'
  end

  def i_dont_see_the_option_to_create_a_ticket_on_the_list
    #save_and_open_page
    within 'table' do
      expect(page).not_to have_link 'Create Ticket' #make sure this is the correct identifier
    end
  end
end
