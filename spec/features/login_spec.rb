require 'spec_helper'

feature 'Login' do
  scenario 'Admin logs in' do
    Given 'I am an admin'
    When 'I log in with my credentials'
    Then 'I see that I am logged in'

    When 'I log out'
    Then 'I see the log in form'
  end

  def i_am_an_admin
    create(:account, :admin, email: 'test@example.com', password: 'password123')
  end

  def i_log_in_with_my_credentials
    login 'test@example.com', 'password123'
  end

  def i_see_that_i_am_logged_in
    expect(page).to have_content 'You have been successfully logged in'
    expect(page).to have_content(/dashboard/i)
    expect(page).to have_content 'Logout'
  end

  def i_log_out
    click_link 'Logout'
  end

  def i_see_the_log_in_form
    expect(page).to have_css('h1', text: 'Login')
    expect(page).to have_content 'You have been successfully logged out'
    expect(page).not_to have_content 'Logout'
  end
end
