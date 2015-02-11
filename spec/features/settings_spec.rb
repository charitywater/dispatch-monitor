require 'spec_helper'

feature 'Settings' do
  scenario 'Updating my account as an admin' do
    Given 'I am logged in as an admin'
    When 'I update my account'
    Then 'I see that my account has been updated'
  end

  scenario 'Updating my subscription settings as an admin' do
    Given 'I am logged in as an admin'
    Then 'I can update my weekly subscription setting'
  end

  scenario 'Updating my account as a program manager' do
    Given 'I am logged in as a program manager'
    When 'I update my account'
    Then 'I see that my account has been updated'
  end

  given!(:admin) { create(:account, :admin, email: 'admin@example.org', weekly_subscription: false) }
  given!(:program_manager) { create(:account, :program_manager, email: 'pm@example.org', weekly_subscription: false) }

  def i_update_my_account
    within('nav') { click_link 'Settings' }

    expect(page).to have_css('h1', 'Settings')

    fill_in 'Name', with: 'Ms. Person With A Name'
    fill_in 'Email', with: 'email@example.com'
    fill_in 'Password', with: '123password'
    select 'America/New_York'

    click_button 'Update Account'
  end

  def i_can_update_my_weekly_subscription_setting
    within('nav') { click_link 'Settings' }
    expect(page).to have_css('h1', 'Settings')

    expect(page).to_not have_checked_field 'Subscribe to weekly reports'

    check 'Subscribe to weekly reports'
    click_button 'Update Account'

    expect(page).to have_checked_field 'Subscribe to weekly reports'
  end

  def i_see_that_my_account_has_been_updated
    expect(page).to have_field 'Name', with: 'Ms. Person With A Name'
    expect(page).to have_field 'Email', with: 'email@example.com'
    expect(page).to have_field 'Time Zone', with: 'America/New_York'

    click_link 'Logout'
    login 'email@example.com', '123password'

    expect(page).to have_content(/dashboard/i)
  end
end
