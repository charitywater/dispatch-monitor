require 'spec_helper'

feature 'List projects' do
  given!(:program_manager) { create(:account, :program_manager, email: 'pm@example.com', program: program) }
  given!(:program) do
    create(
      :program,
      country: create(:country, name: 'Fancy Australia'),
      partner: create(:partner, name: 'Fancy Partner'),
    )
  end

  scenario 'Filtering projects as an admin', :js do
    Given 'There are many projects'
    And 'I am logged in as an admin'
    When 'I am viewing the list of projects'
    Then 'I can filter them by program'
    And 'I can filter them by status'
  end

  scenario 'Viewing projects as a program manager', :js do
    Given 'There are many projects'
    And 'I am logged in as a program manager'
    When 'I am viewing the list of projects'
    Then 'They are filtered to my program'
    And 'I can filter within my program by status'
  end

  def there_are_many_projects
    create_list(:project, 3, :flowing)
    create_list(:project, 2, :needs_maintenance)
    create_list(:project, 6, :unknown)

    create(
      :project,
      :flowing,
      program: program,
      deployment_code: 'FA.NCY.Q1.01.001.001',
      community_name: 'Fancy Community',
      completion_date: '1950-01-01',
      activities: [create(:activity, :completed_construction, happened_at: '1950-01-01')]
    )

    create(
      :project,
      :needs_maintenance,
      program: program,
      deployment_code: 'BR.OKE.N1.01.001.001',
      community_name: 'Fancy Community',
      completion_date: '1950-01-01',
      activities: [create(:activity, :completed_construction, happened_at: '1950-01-01')]
    )
  end

  def i_am_viewing_the_list_of_projects
    visit root_path
    click_on 'Projects'
  end

  def i_can_filter_them_by_program
    select 'Fancy Partner – Fancy Australia', from: 'Program'

    expect(page).to have_content 'FA.NCY.Q1.01.001.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.00'
    expect(current_url).to match(/%255Bprogram_id%255D=\d/)

    select '[Program]', from: 'Program'

    expect(page).to have_content 'AA.AAA.A1.11.111.001'
    expect(page).to have_content 'AA.AAA.A1.11.111.005'
    expect(page).not_to have_content 'FA.NCY.Q1.01.001.001'
    expect(current_url).to match(/%255Bprogram_id%255D=(?!\d)/)
  end

  def i_can_filter_them_by_status
    select 'Flowing', from: 'Status'

    expect(page).to have_content 'AA.AAA.A1.11.111.001'
    expect(page).to have_content 'AA.AAA.A1.11.111.003'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.005'
    expect(current_url).to match(/%255Bstatus%255D=flowing/)

    select '[Status]', from: 'Status'

    expect(page).to have_content 'AA.AAA.A1.11.111.001'
    expect(page).to have_content 'AA.AAA.A1.11.111.005'
    expect(page).not_to have_content 'FA.NCY.Q1.01.001.001'
    expect(current_url).to match(/%255Bstatus%255D=$/)
  end

  def they_are_filtered_to_my_program
    expect(page).to have_content 'FA.NCY.Q1.01.001.001'
    expect(page).to have_content 'BR.OKE.N1.01.001.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.003'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.005'

    expect(page).not_to have_select 'Program'
  end

  def i_can_filter_within_my_program_by_status
    select 'Flowing', from: 'Status'

    expect(page).to have_content 'FA.NCY.Q1.01.001.001'
    expect(page).not_to have_content 'BR.OKE.N1.01.001.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.003'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.005'
    expect(current_url).to match(/%255Bstatus%255D=flowing/)

    select '[Status]', from: 'Status'

    expect(page).to have_content 'FA.NCY.Q1.01.001.001'
    expect(page).to have_content 'BR.OKE.N1.01.001.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.001'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.003'
    expect(page).not_to have_content 'AA.AAA.A1.11.111.005'
    expect(current_url).to match(/%255Bstatus%255D=$/)
  end
end
