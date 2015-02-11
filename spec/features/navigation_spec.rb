require 'spec_helper'

feature 'Navigation', :js do
  scenario 'Admin navigates through the app' do
    Given 'I am logged in as an admin'
    When 'I navigate to the dashboard'
    Then 'I can click to the admin pages'
  end

  scenario 'Program manager navigates through the app' do
    Given 'I am logged in as a program manager'
    When 'I navigate to the dashboard'
    Then 'I can click to the program manager pages'
  end

  scenario 'Viewer navigates through the app' do
    Given 'I am logged in as a viewer'
    When 'I navigate to the dashboard'
    Then 'I can click to the viewer pages'
  end

  scenario 'Viewer does not see settings tab' do
    Given 'I am logged in as a viewer'
    When 'I navigate to the dashboard'
    Then 'I cant see settings'
  end

  scenario 'Logged out user navigates through the app' do
    When 'I am not logged in'
    Then 'I can’t access any of the main pages'
  end

  given!(:program_manager) { create(:account, :program_manager) }
  given!(:viewer) { create(:account, :viewer) }

  def i_navigate_to_the_dashboard
    visit root_path
    i_see_the_dashboard
  end

  def i_can_click_to_the_admin_pages
    visit_map
    visit_projects

    expect(page).to have_link('+ Projects')
    expect(page).to have_link('+ Surveys')

    visit_tickets
    visit_vehicles
    visit_sensors
    visit_accounts
    visit_application_settings
    visit_email_subscriptions
    visit_settings
    visit_dashboard
  end

  def i_see_the_dashboard
    expect(page).to have_css('h1', text: /dashboard/i)
  end

  def i_see_the_disclaimer
    expect(page).to have_content(I18n.t('application.disclaimer.message'))
  end

  def i_am_not_logged_in
  end

  def i_cant_access_any_of_the_main_pages
    [
      root_path,
      new_import_survey_path,
      new_import_project_path,
      projects_path,
      sensors_path,
      tickets_path,
      vehicles_path,
    ].each do |path|
      visit path
      expect(page).to have_css('h1', text: 'Login')
    end
  end

  def i_cant_see_settings
    within('nav') do
      expect(page).not_to have_link('Settings')
    end
  end

  def i_can_click_to_the_program_manager_pages
    expect(page).not_to have_link('Admin')
    expect(page).not_to have_link('Accounts')
    expect(page).not_to have_link('Sensors')

    visit_map
    visit_projects

    expect(page).not_to have_link('+ Projects')
    expect(page).not_to have_link('+ Surveys')

    visit_tickets
    visit_vehicles
    visit_settings
    visit_dashboard
  end

  def i_can_click_to_the_viewer_pages
    expect(page).not_to have_link('Admin')
    expect(page).not_to have_link('Accounts')
    expect(page).not_to have_link('Sensors')

    visit_map
    visit_projects

    expect(page).not_to have_link('+ Projects')
    expect(page).not_to have_link('+ Surveys')

    visit_tickets
    visit_vehicles
    visit_dashboard
  end

  def visit_accounts
    within('nav') do
      hover 'Admin'
      click_link 'Accounts'
    end
    expect(page).to have_css('h1', text: 'Accounts')
    expect(page).to have_css('.active', text: /admin/i)
    expect(page).to have_css('.active', text: /accounts/i)
  end

  def visit_application_settings
    within('nav') do
      hover 'Admin'
      click_link 'DISPATCH Options'
    end
    expect(page).to have_css('h1', text: 'DISPATCH Options')
    expect(page).to have_css('.active', text: /admin/i)
    expect(page).to have_css('.active', text: /dispatch options/i)
  end

  def visit_email_subscriptions
    within('nav') do
      hover 'Admin'
      click_link 'Notifications'
    end
    expect(page).to have_css('h1', text: 'Email Subscriptions')
    expect(page).to have_css('.active', text: /admin/i)
    expect(page).to have_css('.active', text: /notifications/i)
  end

  def visit_dashboard
    within('nav') { click_link 'DISPATCH' }
    i_see_the_dashboard
  end

  def visit_map
    within('nav') { click_link 'Map' }
    expect(page).to have_css('.active', text: /map/i)
  end

  def visit_projects
    within('nav') { click_link 'Projects' }
    expect(page).to have_css('h1', text: 'Project Dashboard')
    expect(page).to have_css('.active', text: /projects/i)
  end

  def visit_vehicles
    within('nav') { click_link 'Vehicles' }
    expect(page).to have_css('h1', text: 'Vehicles')
    expect(page).to have_css('.active', text: /vehicles/i)
  end

  def visit_sensors
    within('nav') { click_link 'Sensors' }
    expect(page).to have_css('h1', text: 'Sensors')
    expect(page).to have_css('.active', text: /sensors/i)
  end

  def visit_settings
    within('nav') { click_link 'Settings' }
    expect(page).to have_css('h1', text: 'Settings')
    expect(page).to have_css('.active', text: /settings/i)
  end

  def visit_tickets
    within('nav') { click_link 'Tickets' }
    expect(page).to have_css('h1', text: 'Tickets')
    expect(page).to have_css('.active', text: /tickets/i)
  end
end
