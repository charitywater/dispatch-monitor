require 'spec_helper'

feature 'List accounts' do
  scenario 'Viewing a list of accounts', :js do
    Given 'There are many accounts'
    And 'I am logged in as an admin'
    When 'I am viewing the list of accounts'
    Then 'I can navigate between pages of accounts'
  end

  scenario 'Deleting an account', :js do
    Given 'There is an account'
    And 'I am logged in as an admin'
    When 'I delete the account'
    Then 'I can no longer see the account'
  end

  def there_are_many_accounts
    country = create(:country, name: 'Fancy Australia')
    partner = create(:partner, name: 'Fancy Partner')
    program = create(:program, partner: partner, country: country)

    create(:account, :program_manager, email: 'aaa@example.com', program: program)
    create_list(:account, 6, :admin)
    create(:account, :program_manager, email: 'zzz@example.com', program: program)
  end

  def i_am_viewing_the_list_of_accounts
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'aaa@example.com'
    expect(page).to have_content 'Fancy Partner – Fancy Australia'
    expect(page).to have_content 'N/A'

    expect(page).not_to have_content 'zzz@example.com'
  end

  def i_can_navigate_between_pages_of_accounts
    click_first_link 'Next'

    expect(page).not_to have_content 'aaa@example.com'
    expect(page).to have_content 'zzz@example.com'

    click_first_link 'First'

    expect(page).to have_content 'aaa@example.com'
    expect(page).not_to have_content 'zzz@example.com'
  end

  def there_is_an_account
    create(:account, email: 'delete-me@example.com')
  end

  def i_delete_the_account
    hover 'Admin'
    click_link 'Accounts'

    expect(page).to have_content 'delete-me@example.com'

    within 'tr', text: 'admin@example.com' do
      expect(page).not_to have_link 'Delete'
    end

    within 'tr', text: 'delete-me@example.com' do
      click_link 'Delete'
    end

    accept_js_alert
  end

  def i_can_no_longer_see_the_account
    within 'table' do
      expect(page).not_to have_content 'delete-me@example.com'
    end
  end
end
