require 'spec_helper'

feature 'Creating accounts' do
  scenario 'Creating an admin and a program manager', :js do
    Given 'There is a program'
    And 'I am logged in as an admin'
    Then 'I can create admin accounts'
    And 'I can create program manager accounts'
  end

  scenario 'Creating a viewer that can view all programs', :js do
    Given 'There is a program'
    And 'I am logged in as an admin'
    Then 'I can create viewer accounts that can view all programs'
  end

  scenario 'Creating a viewer that can view one program', :js do
    Given 'There is a program'
    And 'I am logged in as an admin'
    Then 'I can create viewer accounts that can view one program'
  end

  def there_is_a_program
    france = create(:country, name: 'France')
    partner = create(:partner, name: 'Eau')
    create(:program, partner: partner, country: france)
  end

  def i_can_create_admin_accounts
    i_go_to_the_create_account_page

    fill_in 'Email', with: 'test@example.org'
    fill_in 'Name', with: 'Ms. Test'
    fill_in 'Password', with: 'password123'
    select 'Admin', from: 'Role'

    click_button 'Create Account'

    within 'table' do
      expect(page).to have_content 'test@example.org'
      expect(page).to have_content 'Ms. Test'
      expect(page).to have_content 'Admin'
    end
  end

  def i_can_create_program_manager_accounts
    i_go_to_the_create_account_page

    fill_in 'Email', with: 'program@example.org'
    fill_in 'Name', with: 'Dr. PM III Esq.'
    fill_in 'Password', with: 'password123'

    select 'Program Manager', from: 'Role'
    select 'Eau – France', from: 'Program'

    click_button 'Create Account'

    within 'table' do
      expect(page).to have_content 'program@example.org'
      expect(page).to have_content 'Dr. PM III Esq.'
      expect(page).to have_content 'Program Manager'
    end
  end

  def i_can_create_viewer_accounts_that_can_view_all_programs
    i_go_to_the_create_account_page

    fill_in 'Email', with: 'viewer@example.org'
    fill_in 'Name', with: 'Viewer McViewerson'
    fill_in 'Password', with: 'password123'

    select 'Viewer', from: 'Role'
    select 'All Programs', from: 'Program'

    click_button 'Create Account'

    within 'table' do
      expect(page).to have_content 'viewer@example.org'
      expect(page).to have_content 'Viewer McViewerson'
      expect(page).to have_content 'Viewer'
    end
  end

  def i_can_create_viewer_accounts_that_can_view_one_program
    i_go_to_the_create_account_page

    fill_in 'Email', with: 'viewer@example.org'
    fill_in 'Name', with: 'Viewer McViewerson'
    fill_in 'Password', with: 'password123'

    select 'Viewer', from: 'Role'
    select 'Eau – France', from: 'Program'

    click_button 'Create Account'

    within 'table' do
      expect(page).to have_content 'viewer@example.org'
      expect(page).to have_content 'Viewer McViewerson'
      expect(page).to have_content 'Viewer'
    end
  end

  def i_go_to_the_create_account_page
    visit root_path

    hover 'Admin'
    click_link 'Accounts'
    expect(page).to have_css('h1', text: /account/i)

    click_link '+ Account'
    expect(page).to have_css('h1', text: /add new account/i)
    expect(page).not_to have_select 'Program'
  end
end
