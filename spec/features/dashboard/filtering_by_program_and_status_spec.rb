require 'spec_helper'

feature 'Dashboard: Filtering by Program and Status' do
  scenario 'Filtering as an admin', :js do
    Given 'There are multiple projects'
    And 'I am logged in as an admin'
    When 'I filter by a program'
    Then 'I see only projects in that program'
    And 'I see only tickets in that program'
  end

  scenario 'Viewing as a program manager', :js do
    Given 'There are multiple projects'
    And 'I am logged in as a program manager'
    Then 'I see only projects in my program'
    And 'I see only tickets in my program'
  end

  scenario 'Viewing as a viewer', :js do
    Given 'There are multiple projects'
    And 'I am logged in as a viewer assigned to a program'
    Then 'I see only projects in my program'
    And 'I see only tickets in my program'
  end

  scenario 'Viewing as an all programs viewer', :js do
    Given 'There are multiple projects'
    And 'I am logged in as a viewer'
    When 'I filter by a program'
    Then 'I see only projects in that program'
    And 'I see only tickets in that program'
  end

  given!(:partner) { create(:partner, name: 'Eau') }
  given!(:country) { create(:country, name: 'France') }
  given!(:program) { create(:program, country: country, partner: partner) }
  given!(:program_manager) { create(:account, :program_manager, program: program) }
  given!(:viewer_one_program) { create(:account, :viewer, program: program) }
  given!(:viewer) { create(:account, :viewer, program: nil) }

  def there_are_multiple_projects
    flowing_projects_in_program = create_list(:project, 5, :flowing, program: program).each do |project|
      create(:survey_response, :source_observation_v1, project: project)
      create(:survey_response, :source_observation_v02, project: project)
      create(:survey_response, :maintenance_report_v02, project: project)
    end

    create_list(:project, 3, :needs_maintenance, program: program).each do |project|
      create(:survey_response, :test_source_observation_v02, project: project)
    end

    create_list(:project, 1, :needs_visit, program: program)
    create_list(:project, 4, :unknown, program: program)
    create_list(:project, 2, :inactive, program: program)

    flowing_projects_out_of_program = create_list(:project, 11, :flowing).each do |project|
      create(:survey_response, :test_source_observation_v1, project: project)
    end

    create_list(:project, 7, :needs_maintenance).each do |project|
      create(:survey_response, :source_observation_v1, project: project)
      create(:survey_response, :test_maintenance_report_v02, project: project)
    end

    create_list(:project, 6, :needs_visit)
    create_list(:project, 5, :unknown)
    create_list(:project, 4, :inactive)

    survey_response = flowing_projects_in_program.first.survey_responses.first

    create_list(:ticket, 2, :in_progress, survey_response: survey_response)
    create_list(:ticket, 1, :in_progress, survey_response: survey_response, due_at: 6.days.from_now)
    create_list(:ticket, 7, :overdue, survey_response: survey_response)
    create_list(:ticket, 5, :complete, survey_response: survey_response)
    create(:ticket, :overdue, :deleted, survey_response: survey_response)

    survey_response = flowing_projects_out_of_program.first.survey_responses.first

    create_list(:ticket, 5, :in_progress, survey_response: survey_response)
    create_list(:ticket, 4, :in_progress, survey_response: survey_response, due_at: 6.days.from_now)
    create_list(:ticket, 13, :overdue, survey_response: survey_response)
    create_list(:ticket, 11, :complete, survey_response: survey_response)
  end

  def i_filter_by_a_program
    expect(page).to have_content(/48 projects/i)
    expect(page).to have_css '.gmnoprint'

    expect(page).to have_link '16 Flowing',
      href: projects_path(filters: {status: :flowing, program_id: nil})
    expect(page).to have_link '10 Needs Maintenance',
      href: projects_path(filters: {status: :needs_maintenance, program_id: nil})
    expect(page).to have_link '7 Needs Visit',
      href: projects_path(filters: {status: :needs_visit, program_id: nil})
    expect(page).to have_link '9 Unknown',
      href: projects_path(filters: {status: :unknown, program_id: nil})
    expect(page).to have_link '6 Inactive',
      href: projects_path(filters: {status: :inactive, program_id: nil})
    expect(page).to have_link 'List',
      href: projects_path(filters: {program_id: nil})

    expect(page).to have_content(/32 tickets due/i)
    expect(page).to have_link 'List',
      href: tickets_path(filters: {program_id: nil})

    expect(page).to have_content(/43 field visits/i)
    expect(page).to have_content(/settings filter last 30 days/i)
    expect(page).to have_content(/31\s?Observation/i)
    expect(page).to have_content(/12\s?Maintenance/i)

    select 'Eau – France'
  end

  def i_see_only_projects_in_that_program
    expect(page).to have_content(/15 projects/i)
    expect(page).to have_css '.gmnoprint'

    expect(page).to have_link '5 Flowing',
      href: projects_path(filters: {status: :flowing, program_id: program.id})
    expect(page).to have_link '3 Needs Maintenance',
      href: projects_path(filters: {status: :needs_maintenance, program_id: program.id})
    expect(page).to have_link '1 Needs Visit',
      href: projects_path(filters: {status: :needs_visit, program_id: program.id})
    expect(page).to have_link '4 Unknown',
      href: projects_path(filters: {status: :unknown, program_id: program.id})
    expect(page).to have_link '2 Inactive',
      href: projects_path(filters: {status: :inactive, program_id: program.id})
    expect(page).to have_link 'List',
      href: projects_path(filters: {program_id: program.id})

    expect(page).to have_content(/18 field visits/i)
    expect(page).to have_content(/settings filter last 30 days/i)
    expect(page).to have_content(/13\s?Observation/i)
    expect(page).to have_content(/5\s?Maintenance/i)
  end

  def i_see_only_tickets_in_that_program
    expect(page).to have_content(/10 tickets due/i)
    expect(page).to have_link 'List',
      href: tickets_path(filters: {program_id: program.id})

    expect(page).to have_link '7 Overdue',
      href: tickets_path(filters: {status: :overdue, program_id: program.id})
    expect(page).to have_link '1 Due in 7d',
      href: tickets_path(filters: {status: :in_progress, program_id: program.id})
  end

  def i_am_logged_in_as_a_program_manager
    create(:account, :program_manager, email: 'pm@example.com', program: program)

    login 'pm@example.com', 'password123'
  end

  def i_see_only_projects_in_my_program
    expect(page).not_to have_select 'Program'

    expect(page).to have_content(/15 projects/i)
    expect(page).to have_css '.gmnoprint'

    expect(page).to have_link '5 Flowing',
      href: projects_path(filters: {status: :flowing, program_id: nil})
    expect(page).to have_link '3 Needs Maintenance',
      href: projects_path(filters: {status: :needs_maintenance, program_id: nil})
    expect(page).to have_link '1 Needs Visit',
      href: projects_path(filters: {status: :needs_visit, program_id: nil})
    expect(page).to have_link '4 Unknown',
      href: projects_path(filters: {status: :unknown, program_id: nil})
    expect(page).to have_link '2 Inactive',
      href: projects_path(filters: {status: :inactive, program_id: nil})
    expect(page).to have_link 'List',
      href: projects_path(filters: {program_id: nil})

    expect(page).to have_content(/18 field visits/i)
    expect(page).to have_content(/settings filter last 30 days/i)
    expect(page).to have_content(/13\s?Observation/i)
    expect(page).to have_content(/5\s?Maintenance/i)
  end

  def i_see_only_tickets_in_my_program
    expect(page).to have_content(/10 tickets due/i)
    expect(page).to have_link 'List',
      href: tickets_path(filters: {program_id: nil})

    expect(page).to have_link '7 Overdue',
      href: tickets_path(filters: {status: :overdue, program_id: nil})
    expect(page).to have_link '1 Due in 7d',
      href: tickets_path(filters: {status: :in_progress, program_id: nil})
  end
end
