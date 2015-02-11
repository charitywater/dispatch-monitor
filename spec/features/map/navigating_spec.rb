require 'spec_helper'

feature 'Navigating the map' do
  scenario 'Navigating map by nearby project', :js do
    Given 'There are nearby projects'
    And 'I am logged in as an admin'
    When 'I click on a nearby project'
    Then 'I see the nearby project’s details'
  end

  def there_are_nearby_projects
    create(:project, :needs_maintenance, deployment_code: 'AA.AAA.Q1.11.111.111', latitude: 25, longitude: 52)
    create(:project, :flowing, deployment_code: 'BB.BBB.Q2.22.222.222', latitude: 24.9, longitude: 51.9)
  end

  def i_click_on_a_nearby_project
    visit root_path
    click_on 'Projects'
    click_on 'AA.AAA.Q1.11.111.111'

    expect(page).to have_content('AA.AAA.Q1.11.111.111')
    expect(page).not_to have_content('BB.BBB.Q2.22.222.222')

    nearby_pin = find('.gmnoprint img[src$="flowing16x16.png"]')

    if selenium?
      nearby_pin.click
    else
      nearby_pin.trigger('click')
    end
  end

  def i_see_the_nearby_projects_details
    expect(page).not_to have_content('AA.AAA.Q1.11.111.111')
    expect(page).to have_content('BB.BBB.Q2.22.222.222')
  end
end
