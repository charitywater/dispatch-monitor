require 'spec_helper'

feature 'Map' do
  scenario 'Filtering the map', :js do
    Given 'I am logged in as an admin'
    And 'There are several projects'
    When 'I go to the map page'
    Then 'I can filter the map by project status'
  end

  given(:flowing) { 'flowing16x16.png' }
  given(:inactive) { 'inactive16x16.png' }

  def i_go_to_the_map_page
    within('nav') { click_link 'Map' }

    expect(page).not_to have_css('h1', text: /dashboard/i)
  end

  def there_are_several_projects
    create(:project, :flowing)
    create(:project, :inactive)
  end

  def i_can_filter_the_map_by_project_status
    expect(page).to have_css(%Q|.gmnoprint img[src$="#{flowing}"]|)
    expect(page).to have_css(%Q|.gmnoprint img[src$="#{inactive}"]|)

    select 'Flowing'

    expect(page).to have_css(%Q|.gmnoprint img[src$="#{flowing}"]|)
    expect(page).not_to have_css(%Q|.gmnoprint img[src$="#{inactive}"]|)
    expect(current_url).to match(/%255Bstatus%255D=flowing/)

    select 'Inactive'

    expect(page).to have_css(%Q|.gmnoprint img[src$="#{inactive}"]|)
    expect(page).not_to have_css(%Q|.gmnoprint img[src$="#{flowing}"]|)
    expect(current_url).to match(/%255Bstatus%255D=inactive/)

    select 'All Status'

    expect(page).to have_css(%Q|.gmnoprint img[src$="#{flowing}"]|)
    expect(page).to have_css(%Q|.gmnoprint img[src$="#{inactive}"]|)
    expect(current_url).to match(/%255Bstatus%255D=$/)
  end
end
