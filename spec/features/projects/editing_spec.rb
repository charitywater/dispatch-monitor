require 'spec_helper'

feature 'Editing project details' do
  scenario 'Admin edits', :js do
    Given 'There is a project'
    And 'I am logged in as an admin'
    When 'I edit the project'
    Then 'I see the updated details'
  end

  scenario 'Errors while editing' do
    Given 'There is a project'
    And 'I am logged in as an admin'
    When 'I incorrectly edit the project'
    Then 'I see the error messages'
  end

  scenario 'Program manager tries to edit' do
    Given 'There is a project'
    And 'I am logged in as a program manager'
    When 'I view the project list'
    Then 'I cannot see the edit link'
  end

  given(:program) { create(:program) }
  given(:program_manager) { create(:account, :program_manager, program: program) }

  def there_is_a_project
    create(
      :project,
      community_name: 'Fancy Community',
      program: program,
    )
  end

  def i_edit_the_project
    i_view_the_project_list
    expect(page).not_to have_content 'Fancy Site'

    click_on 'Edit'
    expect(page).not_to have_link 'Edit'

    fill_in 'Site Name', with: 'Fancy Site'
    fill_in 'Cost Actual', with: '30000000'
    fill_in 'Inventory Cost', with: '30000000'
    fill_in 'Latitude', with: '30.45'
    fill_in 'Longitude', with: '-30.54'
    fill_in 'State', with: 'Fancy State'
    fill_in 'District', with: 'Fancy District'
    fill_in 'Sub-District', with: 'Fancy Sub'
    fill_in 'System Name', with: 'Fancy System'
    fill_in 'Water Point Name', with: 'Fancy Water Point'
    fill_in 'Contact Name', with: 'Fancy Contact'
    fill_in 'Contact Email', with: 'fancy.contact@example.com'

    expect(page).not_to have_field 'project_contact_phone_numbers_0'
    click_on 'Add Phone Number'
    expect(page).to have_field 'project_contact_phone_numbers_0'
    fill_in 'project_contact_phone_numbers_0', with: '+1 (234) 567-8900'

    expect(page).not_to have_field 'project_contact_phone_numbers_1'
    click_on 'Add Phone Number'
    expect(page).to have_field 'project_contact_phone_numbers_1'
    fill_in 'project_contact_phone_numbers_1', with: '00 33 123 456'

    expect(page).not_to have_field 'project_contact_phone_numbers_2'
    click_on 'Add Phone Number'
    expect(page).to have_field 'project_contact_phone_numbers_2'

    click_on 'Update Project'

    expect(page).not_to have_button 'Update Project'
  end

  def i_see_the_updated_details
    expect(page).to have_content 'Fancy Community'
    expect(page).to have_content 'Fancy Site'

    click_on 'Edit'
    expect(page).not_to have_link 'Edit'

    expect(page).to have_field 'State', with: 'Fancy State'
    expect(page).to have_field 'District', with: 'Fancy District'
    expect(page).to have_field 'Sub-District', with: 'Fancy Sub'
    expect(page).to have_field 'System Name', with: 'Fancy System'
    expect(page).to have_field 'Water Point Name', with: 'Fancy Water Point'

    expect(page).to have_field 'Contact Name', with: 'Fancy Contact'
    expect(page).to have_field 'Contact Email', with: 'fancy.contact@example.com'
    expect(page).to have_field 'project_contact_phone_numbers_0', with: '+1 (234) 567-8900'
    expect(page).to have_field 'project_contact_phone_numbers_1', with: '00 33 123 456'
    expect(page).not_to have_field 'project_contact_phone_numbers_2'
  end

  def i_incorrectly_edit_the_project
    i_view_the_project_list
    expect(page).not_to have_content 'Fancy Site'

    click_on 'Edit'
    expect(page).not_to have_link 'Edit'

    fill_in 'Latitude', with: '3000000'
    fill_in 'Longitude', with: 'Fancy Longitude'
    fill_in 'Beneficiaries', with: 'Fancy Beneficiaries'

    click_on 'Update Project'
  end

  def i_see_the_error_messages
    expect(page).to have_content 'is not a number'
    expect(page).to have_content 'must be less than or equal to 90.0'
  end

  def i_view_the_project_list
    click_on 'Projects'
    expect(page).to have_content 'Fancy Community'
  end

  def i_cannot_see_the_edit_link
    expect(page).not_to have_content 'Edit'
  end
end
