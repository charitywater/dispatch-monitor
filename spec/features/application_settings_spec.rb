require 'spec_helper'

feature 'Application settings' do
  scenario 'Admin can update application settings' do
    Given 'I am logged in as an admin'
    When 'I visit the application settings page'
    Then 'I can update the application settings'
  end

  scenario 'Program manager cannot update application settings' do
    Given 'I am logged in as a program manager'
    Then 'I cannot update the application settings'
  end

  given!(:program_manager) { create(:account, :program_manager) }
  given!(:application_settings) do
    ApplicationSettings.create(sensors_affect_project_status: false)
  end

  def i_visit_the_application_settings_page
    within('nav') do
      hover 'Admin'
      click_link 'DISPATCH Options'
    end

    expect(page).to have_css('h1', text: /DISPATCH Options/i)
  end

  def i_can_update_the_application_settings
    check 'Sensors affect project status'
    click_button 'Save DISPATCH Options'

    expect(page).to have_content 'options have been successfully updated'
    expect(page).to have_checked_field 'Sensors affect project status'
  end

  def i_cannot_update_the_application_settings
    expect(page).not_to have_content(/DISPATCH Options/i)
  end
end
