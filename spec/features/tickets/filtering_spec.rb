require 'spec_helper'

feature 'Filtering tickets' do
  scenario 'Filtering as an admin', :js do
    turn_off_pagination do
      Given 'There are partners with tickets'
      And 'I am logged in as an admin'
      When 'I am viewing the list of tickets'
      Then 'I can filter them by program'
      And 'I can filter them by status'
    end
  end

  scenario 'Viewing as a program manager', :js do
    turn_off_pagination do
      Given 'There are partners with tickets'
      And 'I am logged in as a program manager'
      When 'I am viewing the list of tickets'
      Then 'The tickets are filtered to my program'
      And 'I can filter within my program by status'
    end
  end

  given!(:admin) { create(:account, :admin, email: 'admin@example.com') }
  given!(:program_manager) { create(:account, :program_manager, email: 'pm@example.com', program: bravo) }

  given!(:alpha) do
    create(
      :program,
      partner: create(:partner, name: 'Alpha Partner'),
      country: create(:country, name: 'Alpha Country'),
    )
  end

  given!(:bravo) do
    create(
      :program,
      partner: create(:partner, name: 'Bravo Partner'),
      country: create(:country, name: 'Bravo Country'),
    )
  end

  def there_are_partners_with_tickets
    create_ticket(:in_progress, alpha, 'AA.AAA.Q1.11.111.111')
    create_ticket(:complete, alpha, 'AA.AAA.Q1.11.111.112')
    create_ticket(:overdue, alpha, 'AA.AAA.Q1.11.111.113')

    create_ticket(:in_progress, bravo, 'AA.AAA.Q1.11.111.114')
    create_ticket(:complete, bravo, 'AA.AAA.Q1.11.111.115')
    create_ticket(:overdue, bravo, 'AA.AAA.Q1.11.111.116')
  end

  def i_am_viewing_the_list_of_tickets
    visit root_path
    click_on 'Tickets'

    expect(page).to have_content(/Deployment Code/i)
    expect(page).to have_content(/Due Date/i)
  end

  def i_can_filter_them_by_program
    expect(page).to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).to have_content 'AA.AAA.Q1.11.111.114'

    select 'Bravo Partner – Bravo Country', from: 'Program'

    expect(page).to have_content 'AA.AAA.Q1.11.111.114'
    expect(page).to have_content 'AA.AAA.Q1.11.111.115'
    expect(page).to have_content 'AA.AAA.Q1.11.111.116'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
    expect(current_url).to match(/%255Bprogram_id%255D=\d/)

    select '[Program]', from: 'Program'

    expect(page).to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).to have_content 'AA.AAA.Q1.11.111.114'
    expect(current_url).to match(/%255Bprogram_id%255D=(?!\d)/)
  end

  def i_can_filter_them_by_status
    expect(page).to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).to have_content 'AA.AAA.Q1.11.111.114'

    select 'Overdue', from: 'Status'

    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).to have_content 'AA.AAA.Q1.11.111.116'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.114'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.115'
    expect(current_url).to match(/%255Bprogram_id%255D=(?!\d)/)
    expect(current_url).to match(/%255Bstatus%255D=overdue/)

    select 'Alpha Partner – Alpha Country', from: 'Program'

    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.116'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.114'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.115'
    expect(current_url).to match(/%255Bprogram_id%255D=\d/)
    expect(current_url).to match(/%255Bstatus%255D=overdue/)

    select '[Program]', from: 'Program'
    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).to have_content 'AA.AAA.Q1.11.111.116'

    select '[Status]', from: 'Status'

    expect(page).to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).to have_content 'AA.AAA.Q1.11.111.114'
    expect(current_url).to match(/%255Bprogram_id%255D=(?!\d)/)
    expect(current_url).to match(/%255Bstatus%255D=$/)
  end

  def create_ticket(status, program, deployment_code)
    create(
      :ticket,
      status,
      survey_response: create(
        :survey_response,
        project: create(
          :project,
          program: program,
          deployment_code: deployment_code,
        ),
      ),
    )
  end

  def the_tickets_are_filtered_to_my_program
    expect(page).to have_content 'AA.AAA.Q1.11.111.114'
    expect(page).to have_content 'AA.AAA.Q1.11.111.115'
    expect(page).to have_content 'AA.AAA.Q1.11.111.116'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.113'

    expect(page).not_to have_select 'Program'
  end

  def i_can_filter_within_my_program_by_status
    select 'Overdue', from: 'Status'

    expect(page).to have_content 'AA.AAA.Q1.11.111.116'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.111'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.112'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.113'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.114'
    expect(page).not_to have_content 'AA.AAA.Q1.11.111.115'
    expect(current_url).to match(/%255Bstatus%255D=overdue/)
  end
end
