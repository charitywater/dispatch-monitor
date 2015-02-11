require 'spec_helper'

feature 'Deleting projects' do
  scenario 'Admin deletes', :js do
    Given 'There is a project'
    And 'I am logged in as an admin'
    When 'I delete the project'
    Then 'I do not see the project in the list'
  end

  scenario 'Program manager tries to delete' do
    Given 'There is a project'
    And 'I am logged in as a program manager'
    When 'I view the project list'
    Then 'I cannot see the delete link'
  end

  given(:program) { create(:program) }
  given(:program_manager) { create(:account, :program_manager, program: program) }

  def there_is_a_project
    create(
      :project,
      program: program,
      deployment_code: 'AA.AAA.Q1.11.111.111',
      community_name: 'Fancy Community',
    )
  end

  def i_delete_the_project
    click_on 'Projects'
    expect(page).to have_content 'Project Dashboard'

    expect(page).to have_content 'Fancy Community'
    click_on 'Delete'
    accept_js_alert
  end

  def i_do_not_see_the_project_in_the_list
    expect(page).to have_content 'Project Dashboard'

    within 'table' do
      expect(page).not_to have_content 'Fancy Community'
    end
  end

  def i_view_the_project_list
    click_on 'Projects'
    expect(page).to have_content 'Project Dashboard'
  end

  def i_cannot_see_the_delete_link
    expect(page).not_to have_link 'Delete'
  end
end
