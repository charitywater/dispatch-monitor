require 'spec_helper'

feature 'Updating accounts' do
  scenario 'Admin updates an account', :js do
    Given 'I am logged in as an admin'
    And 'There is an account'
    When 'I edit the account'
    Then 'The account has changed'
  end

  scenario 'Admin updates an account — does not change password', :js do
    Given 'I am logged in as an admin'
    And 'There is an account'
    When 'I edit only the email'
    Then 'Only the email has changed'
  end

  scenario 'Admin updates a viewer account to one program', :js do
    Given 'I am logged in as an admin'
    And 'There is a viewer account'
    When 'I assign a program'
    Then 'The viewer is assigned a program'
  end

  scenario 'Admin updates a viewer account to all programs', :js do
    Given 'I am logged in as an admin'
    And 'There is a viewer account'
    When 'I assign all programs'
    Then 'The viewer is assigned all programs'
  end

  def there_is_an_account
    france = create(:country, name: 'France')

    eau = create(:partner, name: 'Eau')
    lait = create(:partner, name: 'Lait')

    program = create(:program, partner: eau, country: france)

    create(:program, partner: lait, country: france)
    create(:account, :program_manager, email: 'joe@example.com', program: program)
  end

  def there_is_a_viewer_account
    france = create(:country, name: 'France')

    eau = create(:partner, name: 'Eau')
    lait = create(:partner, name: 'Lait')

    @eau_program = create(:program, partner: eau, country: france)
    @lait_program = create(:program, partner: lait, country: france)

    create(:account, :viewer, email: 'viewer@example.com', program: @eau_program)
  end

  def i_assign_a_program
    visit root_path
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'viewer@example.com'

    within 'tr', text: 'viewer@example.com' do
      click_link 'Edit'
    end

    expect(page).to have_select 'Role', disabled: true

    within 'select#account_program_id' do
      select 'Lait'
    end

    click_button 'Update Account'
  end

  def i_assign_all_programs
    visit root_path
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'viewer@example.com'

    within 'tr', text: 'viewer@example.com' do
      click_link 'Edit'
    end

    select 'All Programs', from: 'Program'

    expect(page).to have_select 'Role', disabled: true

    click_button 'Update Account'
  end

  def the_viewer_is_assigned_all_programs
    expect(page).to have_css('h1', text: /account/i)

    within 'tr', text: 'viewer@example.com' do
      click_link 'Edit'
    end

    expect(find_field('account_program_id').value).to be_empty
  end

  def i_edit_the_account
    visit root_path
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'joe@example.com'

    within 'tr', text: 'joe@example.com' do
      click_link 'Edit'
    end

    fill_in 'Name', with: 'Joe Seph'
    fill_in 'Email', with: 'joseph@example.com'
    fill_in 'Password', with: '123password'
    select 'Lait – France', from: 'Program'

    expect(page).to have_select 'Role', disabled: true

    click_button 'Update Account'
  end

  def the_account_has_changed
    expect(page).to have_css('h1', text: /account/i)

    within 'table' do
      expect(page).to have_content 'Joe Seph'
      expect(page).to have_content 'joseph@example.com'
    end

    within 'tr', text: 'joseph@example.com' do
      click_link 'Edit'
    end

    expect(page).to have_select 'Program', selected: 'Lait – France'

    click_on 'Logout'
    login('joseph@example.com', '123password')

    expect(page).to have_content(/dashboard/i)
  end

  def the_viewer_is_assigned_a_program
    expect(page).to have_css('h1', text: /account/i)

    within 'tr', text: 'viewer@example.com' do
      click_link 'Edit'
    end

    # no other selector was working except find_field
    expect(find_field('account_program_id').value).to eq @lait_program.id.to_s
  end

  def i_edit_only_the_email
    visit root_path
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'joe@example.com'

    within 'tr', text: 'joe@example.com' do
      click_link 'Edit'
    end

    fill_in 'Email', with: 'john@example.com'
    click_button 'Update Account'
  end

  def only_the_email_has_changed
    expect(page).to have_css('h1', text: /account/i)

    within 'table' do
      expect(page).to have_content 'john@example.com'
    end
  end
end
