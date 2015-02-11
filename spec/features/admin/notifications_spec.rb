require 'spec_helper'

feature 'Notifications' do
  scenario 'Admin can add a name/email pair to the list' do
    Given 'There are accounts'
    And 'I am logged in as an admin'
    When 'I add an account to the list'
    Then 'I see the new account in the list'
  end

  scenario 'Admin can remove a name/email pair from the list' do
    Given 'There are accounts'
    And 'I am logged in as an admin'
    When 'I remove an account from the list'
    Then 'I do not see the removed account in the list'
  end

  def there_are_accounts
    miguel = create(
      :account,
      :program_manager,
      name: 'Miguel Ball',
      email: 'miguel.ball@example.com'
    )
    create(
      :account,
      :program_manager,
      name: 'Lynn Anderson',
      email: 'lynn.anderson@example.com'
    )

    create(
      :email_subscription,
      :bulk_import_notifications,
      account: miguel,
    )
  end

  def i_add_an_account_to_the_list
    hover 'Admin'
    click_link 'Notifications'

    expect(page).to have_css('h1', text: /^Email Subscriptions/i)
    within 'table' do
      expect(page).to have_content 'Miguel Ball'
      expect(page).to have_content 'miguel.ball@example.com'
      expect(page).not_to have_content 'Lynn Anderson'
      expect(page).not_to have_content 'lynn.anderson@example.com'
    end

    click_link '+ Subscription'

    expect(page).to have_css('h1', text: /^Add Email Subscription$/i)
    expect(page).to have_select 'Account', with_options: ['Lynn Anderson <lynn.anderson@example.com>']
    select 'Lynn Anderson <lynn.anderson@example.com>'

    click_button 'Add Subscription'
    expect(page).to have_content 'Lynn Anderson <lynn.anderson@example.com> has been successfully subscribed to Bulk Import Notifications'
    expect(page).to have_select 'Account'
    expect(page).not_to have_select 'Account', with_options: ['Lynn Anderson <lynn.anderson@example.com>']
  end

  def i_see_the_new_account_in_the_list
    click_link 'Email Subscriptions'

    within 'table' do
      expect(page).to have_content 'Miguel Ball'
      expect(page).to have_content 'miguel.ball@example.com'
      expect(page).to have_content 'Lynn Anderson'
      expect(page).to have_content 'lynn.anderson@example.com'
    end
  end

  def i_remove_an_account_from_the_list
    hover 'Admin'
    click_link 'Notifications'

    expect(page).to have_css('h1', text: /^Email Subscriptions/i)

    within 'tr', text: 'Miguel Ball' do
      click_on 'Delete'
    end

    expect(page).to have_content 'Miguel Ball <miguel.ball@example.com> has been successfully unsubscribed from Bulk Import Notifications'
  end

  def i_do_not_see_the_removed_account_in_the_list
    within 'table' do
      expect(page).not_to have_content 'Miguel Ball'
    end
  end
end
